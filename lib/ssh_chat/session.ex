require IEx
require Logger

defmodule SshChat.Session do
  use GenServer

  def start_link(user_name, input_pid) do
    GenServer.start_link(__MODULE__, {:ok, user_name, input_pid}, [])
  end

  # --- Client API

  def receive(recipient, message) do
    GenServer.cast(recipient.pid, {:message, message})
  end

  def register_user(user) do
    GenServer.cast(user.pid, {:register_user, user})
  end

  def stop(user) do
    GenServer.cast(user.pid, {:stop, user})
  end

  # --- Callbacks ---

  def init({:ok, user_name, input_pid}) do
    user = User.new(user_name, input_pid)
    register_user(user)
    SshChat.Input.wait(user)
    {:ok, user}
  end

  def handle_cast({:register_user, user}, user) do
    SshChat.Room.register(user)
    {:noreply, user}
  end

  def handle_cast({:stop, user}, user) do
    SshChat.Room.unregister(user)

    {:stop, :normal, user}
  end

  def handle_cast({:message, message}, user) do
    User.receive(user, message)

    {:noreply, user}
  end

  def handle_info(_, user) do
    {:noreply, user}
  end
end
