require IEx
require Logger

defmodule SshChat.Session do
  use GenServer

  def shell(user_name) do
    # child_pid = the process id of the new child of SessionSupervisor
    # which is SshChat.Session (the current module). As a result,
    # start_link (below) is called with [user_name]
    {:ok, shell_session_pid} = Supervisor.start_child(SshChat.SessionSupervisor, [user_name])

    spawn fn ->
      Process.link(shell_session_pid)

      # set the group leader to the same process as the shellsession pid
      Process.group_leader(shell_session_pid, Process.group_leader)

      input_loop(%User{name: user_name, pid: shell_session_pid})
    end
  end

  def input_loop(user) do
    case IO.gets("#{user.name} > ") do
      {:error, :interrupted} -> GenServer.stop(user.pid, :normal)
      {:error, reason} -> GenServer.stop(user.pid, {:error, reason})

      message ->
        SshChat.Room.message(%Message{sender: user, text: String.trim(to_string(message))})
        input_loop(user)
    end
  end

  # --- GenServer Client

  def start_link(user_name) do
    GenServer.start_link(__MODULE__, {:ok, user_name}, [])
  end

  def send_message(recipient, message) do
    GenServer.cast(recipient.pid, {:message, message})
  end

  # --- GenServer Callbacks ---

  def init({:ok, user_name}) do
    user = %User{pid: self(), name: user_name}
    SshChat.Room.register(user)
    {:ok, user}
  end

  def handle_cast({:message, message}, user) do
    User.receive(user, message)
    {:noreply, user}
  end
end
