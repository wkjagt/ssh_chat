defmodule SshChat.SessionSupervisor do
  use Supervisor

  @name SshChat.SessionSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      worker(SshChat.Session, [], restart: :temporary),
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
 end
