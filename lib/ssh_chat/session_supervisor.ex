defmodule SshChatSession.Supervisor do
  use Supervisor

  @name SshChatSession.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      worker(SshChatSession, [], restart: :temporary),
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
 end
