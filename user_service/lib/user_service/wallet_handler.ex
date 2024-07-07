defmodule UserService.WalletHandler do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get_wallet, message_id}, _from, state) do
    wallet = Map.get(state, message_id)
    {:reply, wallet, state}
  end

  def handle_cast({:store_wallet, message_id, wallet}, state) do
    new_state = Map.put(state, message_id, wallet)
    {:noreply, new_state}
  end

  def get_wallet(message_id) do
    GenServer.call(__MODULE__, {:get_wallet, message_id})
  end

  def store_wallet(message_id, wallet) do
    GenServer.cast(__MODULE__, {:store_wallet, message_id, wallet})
  end
end
