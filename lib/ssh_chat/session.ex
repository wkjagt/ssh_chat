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

  # --- Callbacks ---

  def init({:ok, user_name, input_pid}) do
    user = User.new(user_name, input_pid)
    SshChat.Room.register(user)
    SshChat.Input.wait(user)

    {:ok, user}
  end

  def handle_cast({:message, message}, user) do
    User.receive(user, message)
    SshChat.Input.wait(user)

    {:noreply, user}
  end

  def handle_info(_, user) do
    {:noreply, user}
  end
end
