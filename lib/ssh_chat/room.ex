require IEx
require Logger

defmodule SshChat.Room do
  use GenServer

  @name __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def register(user) do
    announce("#{user.name} joined")
    GenServer.cast(@name, {:register, user})
  end

  def announce(text) do
    GenServer.cast(@name, {:announce, %Message{sender: nil, text: text}})
  end

  def message(message) do
    GenServer.cast(@name, {:message, message})
  end

  # --- Callbacks ---

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:register, user}, users) do
    Process.monitor(user.pid)
    {:noreply, Map.put(users, user.pid, user)}
  end

  def handle_cast({:announce, message}, users) do
    send_to_users(users, message)
    {:noreply, users}
  end

  def handle_cast({:message, message}, users) do
    send_to_users(users, message)
    {:noreply, users}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, users) do
    case Map.fetch(users, pid) do
      {:ok, user} -> announce("#{user.name} left")
      {:error} -> nil
    end

    {:noreply, Map.delete(users, pid)}
  end

  defp send_to_users(users, message) do
    Enum.each(users, fn {_, user} -> send_to_user(user, message) end)
  end

  defp send_to_user(user, message) do
    SshChat.Session.receive(user, message)
  end
end
