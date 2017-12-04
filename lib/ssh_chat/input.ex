require IEx

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
    prompt = [:green, user.name, :reset, ": "] |> IO.ANSI.format(true)

    case IO.gets(prompt) do
      {:error, :interrupted} ->
        IO.puts("\nYou logged off")
        SshChat.Session.stop(user)
        {:stop, :normal, nil}
      message ->
        SshChat.Room.message(%Message{sender: user, text: String.trim(to_string(message))})
        wait(user)
        {:noreply, nil}
    end
  end
end
