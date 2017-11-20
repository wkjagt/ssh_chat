defmodule SshChatSupervisor do
  use Supervisor

  @name SshChatSupervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, name: @name)
  end

  def init(config) do
    children = [
      worker(SshChatDaemon, [config]),
      supervisor(SshChatSession.Supervisor, []),
      worker(SshChatRoom, []),
    ]

    supervise(children, strategy: :rest_for_one)
  end
end
