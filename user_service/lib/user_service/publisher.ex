defmodule UserService.Publisher do
  use AMQP
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def publish_message(payload, queue_name) do
    GenServer.cast(__MODULE__, {:publish, queue_name, payload})
  end

  # server callback
  def init(_) do
    {:ok, connection} = Connection.open("amqp://guest:guest@localhost:5672")
    {:ok, channel} = Channel.open(connection)
    {:ok, %{connection: connection, channel: channel}}
  end

  def handle_cast({:publish, queue_name, payload}, state) do
    :ok = Basic.publish(state.channel, "", queue_name, payload, persistent: true)
    Logger.info("Publish #{payload} to #{queue_name} queue")
    {:noreply, state}
  end

  def terminate(_reason, %{connection: connection, channel: channel}) do
    :ok = Channel.close(channel)
    :ok = Connection.close(connection)
  end
end
