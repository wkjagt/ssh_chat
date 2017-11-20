defmodule SshChat do
  use Application

  def start(_type, _args) do
    SshChatSupervisor.start_link
  end
end
