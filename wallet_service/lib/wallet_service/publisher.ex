defmodule WalletService.Publisher do
  use AMQP

  def publish_message(payload) do
    {:ok, connection} = Connection.open("amqp://guest:guest@localhost:5672")
    {:ok, channel} = Channel.open(connection)
    queue = "user_queue"

    {:ok, _queue_info} = Queue.declare(channel, queue, durable: true)
    :ok = Basic.publish(channel, "", queue, payload, persistent: true)

    IO.puts(" [x] Sent #{payload}")

    :ok = Channel.close(channel)
    :ok = Connection.close(connection)
  end
end
