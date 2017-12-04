defmodule SshChat do
  use Application

  def start(_type, _args) do
    config = %{
      port: Application.get_env(:ssh_chat, :port),
      max_sessions: Application.get_env(:ssh_chat, :max_sessions),
      key_dir: :code.priv_dir(:ssh_chat),
    }

    SshChat.Supervisor.start_link(config)
  end
end
