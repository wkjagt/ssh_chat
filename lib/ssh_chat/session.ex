require IEx

defmodule SshChat.Session do
  use GenServer

  def start(user_name) do
    {:ok, child_pid} = Supervisor.start_child(SshChat.SessionSupervisor, [user_name])

    # supervise this?
    spawn fn ->
      Process.link(child_pid)
      Process.group_leader(child_pid, Process.group_leader)

      input_loop(%User{name: user_name, pid: child_pid})
    end
  end

  def input_loop(user) do
    case IO.gets("#{user.name} > ") do
      {:error, :interrupted} -> GenServer.stop(user.pid, :normal)
      {:error, reason} -> GenServer.stop(user.pid, {:error, reason})

      msg ->
        SshChat.Room.message(user, String.trim(to_string(msg)))
        input_loop(user)
    end
  end

  # --- GenServer Client

  def start_link(user) do
    GenServer.start_link(__MODULE__, {:ok, user}, [])
  end

  def send_message(pid, msg) do
    GenServer.cast(pid, {:message, msg})
  end

  # --- GenServer Callbacks ---

  def init({:ok, user}) do
    user = %User{pid: self(), name: "#{user}"}
    SshChat.Room.register(user)
    {:ok, []}
  end

  def handle_cast({:message, msg}, state) do
    IO.puts(msg)
    {:noreply, state}
  end
end
