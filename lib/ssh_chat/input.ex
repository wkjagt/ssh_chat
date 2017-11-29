defmodule SshChat.Input do
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  # Client

  def wait(user) do
    GenServer.cast(user.input_pid, {:wait, user})
  end

  # Server

  def init(:ok) do
    {:ok, nil}
  end

  def handle_cast({:wait, user}, _) do
    case IO.gets("#{user.name} > ") do
      {:error, :interrupted} -> GenServer.stop(user.pid, :normal)
      {:error, reason} -> GenServer.stop(user.pid, {:error, reason})

      message ->
        SshChat.Room.message(%Message{sender: user, text: String.trim(to_string(message))})
    end

    {:noreply, nil}
  end
end
