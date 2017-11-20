defmodule SshChat.Session do
  use GenServer

  def start(user, addr) do
    {:ok, child_pid} = Supervisor.start_child(SshChat.SessionSupervisor, [user, addr])

    # supervise this?
    spawn fn ->
      Process.link(child_pid)
      Process.group_leader(child_pid, Process.group_leader)

      initialize_io_loop(user, child_pid)
    end
  end

  defp initialize_io_loop(user, session_pid) do
    IO.puts("Welcome to Elixir SshChat")
    input_loop({user, session_pid})
  end

  def input_loop({user, pid} = state) do
    case IO.gets("#{user} > ") do
      {:error, :interrupted} -> GenServer.stop(pid, :normal)
      {:error, reason} -> GenServer.stop(pid, {:error, reason})

      msg ->
        SshChat.Room.message(pid, String.trim(to_string(msg)))
        input_loop(state)
    end
  end

  # --- GenServer Client

  def start_link(user, addr) do
    GenServer.start_link(__MODULE__, {:ok, user, addr}, [])
  end


  def send_message(pid, msg) do
    GenServer.cast(pid, {:message, msg})
  end

  # --- GenServer Callbacks ---

  def init({:ok, user, _addr}) do
    # user is a charlist, we want strings
    SshChat.Room.register(self(), "#{user}")
    {:ok, []}
  end

  def handle_cast({:message, msg}, state) do
    IO.puts(msg)
    {:noreply, state}
  end
end