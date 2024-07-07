defmodule UserService.TransactionHandler do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get_transaction, message_id}, _from, state) do
    trans = Map.get(state, message_id)
    {:reply, trans, state}
  end

  def handle_cast({:store_transaction, user_id, transaction}, state) do
    updated_state =
      Map.update(state, user_id, %{user_id: user_id, transactions: [transaction]}, fn user ->
        %{user | transactions: [transaction]}
      end)

    {:noreply, updated_state}
  end

  def get_transaction(message_id) do
    GenServer.call(__MODULE__, {:get_transaction, message_id})
  end

  def store_transaction(message_id, transaction) do
    GenServer.cast(__MODULE__, {:store_transaction, message_id, transaction})
  end
end
