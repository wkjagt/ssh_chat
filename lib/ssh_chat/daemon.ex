defmodule SshChatDaemon do
  def start_link(%{port: port, max_sessions: max_sessions}) do
    :ssh.daemon(port,
      system_dir: Path.join(File.cwd!, "priv") |> to_charlist,
      key_cb: SshChatNopKeyApi,
      shell: &SshChatSession.start_session(&1,&2),
      parallel_login: true,
      max_sessions: max_sessions
    )
  end
end
