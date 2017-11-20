defmodule SshChat.Mixfile do
  use Mix.Project

  def project do
    [
      app: :telnet_chat,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {SshChat.Application, []},
      extra_applications: [:logger, :ssh]
    ]
  end

  defp deps do
    [
      {:gettext, "~> 0.11"},
    ]
  end
end
