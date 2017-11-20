defmodule SshChat do
  use Application

  def start(_type, _args) do
    SshChat.SSH.Supervisor.start_link
  end
end
