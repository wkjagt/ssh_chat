defmodule SshChat.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(SshChat.SSH.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: SshChat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
