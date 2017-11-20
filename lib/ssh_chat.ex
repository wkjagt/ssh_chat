defmodule SshChat do
  use Application

  def start(_type, _args) do
    config = %{
      port: Application.get_env(:ssh_chat, :port, 2222),
      max_sessions: Application.get_env(:max_sessions, :port, 1000)
    }

    SshChat.Supervisor.start_link(config)
  end
end
