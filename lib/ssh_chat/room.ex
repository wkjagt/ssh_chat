require IEx

defmodule SshChat.Room do
  use GenServer

  @name __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def register(pid, name) do
    announce("#{name} joined")
    GenServer.cast(@name, {:register, pid, name})
  end

  def announce(message) do
    GenServer.cast(@name, {:announce, message})
  end

  def message(from, message) do
    GenServer.cast(@name, {:message, from, message})
  end

  # --- Callbacks ---

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:register, pid, name}, sessions) do
    Process.monitor(pid)
    {:noreply, Map.put(sessions, pid, name)}
  end

  def handle_cast({:announce, message}, sessions) do
    send_to_others(message, nil, sessions)
    {:noreply, sessions}
  end

  def handle_cast({:message, from, message}, sessions) do
    send_to_others(message, from, sessions)
    {:noreply, sessions}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, sessions) do
    {name, sessions} = Map.pop(sessions, pid)
    announce("#{name} left")
    {:noreply, sessions}
  end

  defp send_to_others(message, from, sessions) do
    Enum.each sessions, fn {pid, _name} ->
      unless pid == from do
        SshChat.Session.send_message(pid, "#{sessions[from]}: #{message}")
      end
    end
  end
end
