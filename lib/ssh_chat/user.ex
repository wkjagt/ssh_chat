defmodule User do
  defstruct [:pid, :name, :input_pid]

  def new(name, input_pid) do
    %User{
      pid: self(),
      name: name,
      input_pid: input_pid
    }
  end

  def receive(_user, %Message{sender: nil, text: text}) do
    ["** ", :red, :bright, text, :reset, " **"] |> format
  end

  def receive(user, %Message{sender: sender, text: text}) do
    unless user == sender do
      [:bright, sender.name, :reset, ": ", text] |> format
    end
  end

  defp format(text) do
    text |> IO.ANSI.format(true) |> IO.puts
  end
end