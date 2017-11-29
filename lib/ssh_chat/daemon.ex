defmodule SshChat.Daemon do
  def start_link(%{port: port, max_sessions: max_sessions}) do
    :ssh.daemon(port,
      system_dir: Path.join(File.cwd!, "priv") |> to_charlist,
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
