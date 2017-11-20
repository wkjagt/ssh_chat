defmodule SshChatSupervisor do
  use Supervisor

  @name SshChatSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      worker(SshChatDaemon, []),
      supervisor(SshChatSession.Supervisor, []),
      worker(SshChatRoom, []),
    ]

    supervise(children, strategy: :rest_for_one)
  end
end
