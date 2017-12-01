defmodule SshChat.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ssh_chat,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {SshChat, []},
      extra_applications: [:logger, :ssh]
    ]
  end

  defp deps do
    [
    ]
  end
end
