defmodule SshChat.Session do
  use GenServer

  def start(user) do
    {:ok, child_pid} = Supervisor.start_child(SshChat.SessionSupervisor, [user])

    # supervise this?
    spawn fn ->
      Process.link(child_pid)
      Process.group_leader(child_pid, Process.group_leader)

      input_loop(user, child_pid)
    end
  end

  def input_loop(user, pid) do
    case IO.gets("#{user} > ") do
      {:error, :interrupted} -> GenServer.stop(pid, :normal)
      {:error, reason} -> GenServer.stop(pid, {:error, reason})

      msg ->
        SshChat.Room.message(pid, String.trim(to_string(msg)))
        input_loop(user, pid)
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
    SshChat.Room.register(self(), "#{user}")
    {:ok, []}
  end

  def handle_cast({:message, msg}, state) do
    IO.puts(msg)
    {:noreply, state}
  end
end
