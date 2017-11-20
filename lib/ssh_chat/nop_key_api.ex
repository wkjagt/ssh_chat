require Logger

defmodule SshChat.NopKeyApi do
  @behaviour :ssh_server_key_api

  def host_key(algorithm, props) do
    :ssh_file.host_key(algorithm, props)
  end

  def is_auth_key(key, user, _options) do
    Logger.info("Authorized #{user}")
    true
  end
end
