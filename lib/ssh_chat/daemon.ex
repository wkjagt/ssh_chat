require IEx
require Logger

defmodule SshChat.Daemon do
  def start_link(%{port: port, max_sessions: max_sessions, key_dir: key_dir}) do
    Logger.info("Starting SSH daemon with config:")
    Logger.info("Port: #{port}")
    Logger.info("Max sessions: #{max_sessions}")
    Logger.info("Key dir: #{key_dir}")

    :ssh.daemon(port,
      system_dir: key_dir |> to_charlist,
      key_cb: SshChat.NopKeyApi,
      shell: fn user_name ->
        {:ok, input_pid} = SshChat.Input.start_link
        {:ok, shell_session_pid} = Supervisor.start_child(SshChat.SessionSupervisor, [user_name, input_pid])

        Process.group_leader(shell_session_pid, self())

        input_pid
      end,
      parallel_login: true,
      max_sessions: max_sessions
    )
  end
end
