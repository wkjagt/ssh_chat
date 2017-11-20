# require Logger
# require IEx

# defmodule SshChat do
#   use Application

#   def start(_type, _args) do
#     port = Application.get_env :telnet_chat, :port, 2222

#     SshChat.SSH.Supervisor.start_link([port])
#   end
# end