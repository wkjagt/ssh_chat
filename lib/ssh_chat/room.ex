require IEx

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
    {:ok, MapSet.new}
  end

  def handle_cast({:register, user}, users) do
    Process.monitor(user.pid)
    {:noreply, MapSet.put(users, user)}
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
    {name, users} = MapSet.delete(users, pid)
    announce("#{name} left")
    {:noreply, users}
  end

  defp send_to_users(users, message) do
    Enum.each(users, &send_to_user(&1, message))
  end

  defp send_to_user(user, message) do
    SshChat.Session.send_message(user, message)
  end
end
