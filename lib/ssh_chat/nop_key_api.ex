require Logger

defmodule SshChat.NopKeyApi do
  @behaviour :ssh_server_key_api

  def host_key(algorithm, props) do
    :ssh_file.host_key(algorithm, props)
  end

  def is_auth_key(_key, _user, _options) do
    true
  end
end
