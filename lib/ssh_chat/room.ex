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

  def unregister(user) do
    GenServer.cast(@name, {:unregister, user})
  end

  def announce(text) do
    GenServer.cast(@name, {:announce, %Message{sender: nil, text: text}})
  end

  def private_announce(recipient, text) do
    private_message(nil, recipient, text)
  end

  def message(message) do
    GenServer.cast(@name, {:message, message})
  end

  def private_message(sender, recipient, text) do
    GenServer.cast(@name, {
      :private_message,
      recipient,
      %Message{sender: sender, text: text}
    })
  end

  # --- Callbacks ---

  def init(:ok) do
    state = %{
      name: "Main Room",
      users: %{},
      history: [],
    }
    {:ok, state}
  end

  def handle_cast({:register, user}, room) do
    Process.monitor(user.pid)

    Enum.each(room.history, fn message ->
      GenServer.cast(@name, {:private_message, user, message})
    end)
    private_announce(user, "Welcome to #{room.name}, #{user.name}!")

    {:noreply, %{room | users: Map.put(room.users, user.pid, user)}}
  end

  def handle_cast({:unregister, user}, room) do
    Process.monitor(user.pid)
    announce("#{user.name} left")

    {:noreply, %{room | users: Map.delete(room.users, user.pid)}}

    # Enum.each(room.history, fn message ->
    #   GenServer.cast(@name, {:private_message, user, message})
    # end)
    # private_announce(user, "Welcome to #{room.name}, #{user.name}!")

    # {:noreply, %{room | users: Map.put(room.users, user.pid, user)}}
  end

  def handle_cast({:announce, message}, room) do
    send_to_users(room.users, message)
    {:noreply, room}
  end

  def handle_cast({:private_message, recipient, message}, room) do
    send_to_user(recipient, message)
    {:noreply, room}
  end

  def handle_cast({:message, message}, room) do
    send_to_users(room.users, message)
    {:noreply, %{room | history: room.history ++ [message]}}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, room) do

  #   case Map.fetch(room.users, pid) do
  #     {:ok, user} -> announce("#{user.name} left")
  #     {:error} -> nil
  #   end
      {:noreply, room}
  #   {:noreply, %{room | users: Map.delete(room.users, pid)}}
  end

  defp send_to_users(users, message) do
    Enum.each(users, fn {_, user} -> send_to_user(user, message) end)
  end

  defp send_to_user(user, message) do
    SshChat.Session.receive(user, message)
  end
end
