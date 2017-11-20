defmodule SshChat.SSH.Daemon do
  def start_link do
    :ssh.daemon(4000,
      system_dir: Path.join(File.cwd!, "priv") |> to_charlist,
      key_cb: SshChat.SSH.NopKeyApi,
      shell: &SshChat.SSH.Session.start_session(&1,&2),
      parallel_login: true,
      max_sessions: 100000, # how many can I take?
    )
  end
end
