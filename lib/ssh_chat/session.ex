require IEx
require Logger

defmodule SshChat.Session do
  use GenServer

  def shell(user_name) do
    {:ok, input_pid} = SshChat.Input.start_link
    {:ok, shell_session_pid} = Supervisor.start_child(SshChat.SessionSupervisor, [user_name, input_pid])

    Process.group_leader(shell_session_pid, self())

    input_pid
  end

  # --- GenServer Client

  def start_link(user_name, input_pid) do
    GenServer.start_link(__MODULE__, {:ok, user_name, input_pid}, [])
  end

  def send_message(recipient, message) do
    GenServer.cast(recipient.pid, {:message, message})
  end

  # --- GenServer Callbacks ---

  def init({:ok, user_name, input_pid}) do
    user = %User{pid: self(), name: user_name, input_pid: input_pid}
    SshChat.Room.register(user)
    SshChat.Input.wait(user)

    {:ok, user}
  end

  def handle_cast({:message, message}, user) do
    User.receive(user, message)
    SshChat.Input.wait(user)

    {:noreply, user}
  end

  def handle_info(whatever, user) do
    Logger.info(inspect(whatever))
    {:noreply, user}
  end
end
