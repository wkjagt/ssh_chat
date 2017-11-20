defmodule SshChat.Supervisor do
  use Supervisor

  @name SshChat.Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, name: @name)
  end

  def init(config) do
    children = [
      worker(SshChat.Daemon, [config]),
      supervisor(SshChat.SessionSupervisor, []),
      worker(SshChat.Room, []),
    ]

    supervise(children, strategy: :rest_for_one)
  end
end
