defmodule SshChat.SSH.Daemon do
  @key_dir '/Users/maxim/projects/sshchat/ssh_dir/' #this *has* to be a charlist because erlang

  def start_link do
    # port = Application.get_env(:ssh_chat, :port)
    :ssh.daemon(4000,
      system_dir: Path.join(File.cwd!, "priv") |> to_charlist,
      key_cb: SshChat.SSH.NopKeyApi,
      shell: &SshChat.SSH.Session.start_session(&1,&2),
      parallel_login: true,
      max_sessions: 100000, # how many can I take?
    )
  end
end
