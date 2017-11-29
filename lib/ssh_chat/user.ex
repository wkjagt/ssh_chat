defmodule User do
  defstruct [:pid, :name, :input_pid]

  def same?(user1, user2) do
    user1.pid == user2.pid
  end

  def receive(_user, %Message{sender: nil, text: text}) do
    IO.puts "** #{text} **"
  end

  def receive(user, %Message{sender: sender, text: text}) do
    unless same?(user, sender) do
      IO.puts "#{sender.name}: #{text}"
    end
  end
end