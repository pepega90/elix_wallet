is a microservices-based wallet application built using Elixir, Phoenix, and Broadway (RabbitMQ). This application allows users to manage their wallet balances, view transaction history, and transfer funds to other users. The architecture includes separate services for user management and wallet operations, each with its own database.

## Architecture Diagram

![Microservices Architecture Diagram](https://github.com/pepega90/wallet_microservices/blob/main/diag.png)

## Features

- Wallet Balance Management
- Transaction History
- Top-Up Wallet
- Transfer Balance to Other Users
- Inter-service communication using RabbitMQ

## Services

### User Service
- **Port**: 4000
- **Technology**: Elixir, Phoenix, GenServer
- **Database**: user_service_db

### Wallet Service
- **Port**: 4001
- **Description**: Manages wallet operations such as top-ups and transfers.
- **Technology**: Elixir, Phoenix
- **Database**: wallet_service_dev

## Communication

- **Message Broker**: RabbitMQ (using Broadway for message processing)
- The gateway service sends messages to RabbitMQ, which routes them to the appropriate service (User Service or Wallet Service).

## Getting Started

### Prerequisites

- Elixir
- Phoenix Framework
- RabbitMQ
- Broadway
- Docker (optional, for easier setup)

### Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/pepega90/wallet_microservices.git
    cd walletwave
    ```

2. Set up User Service:
    ```bash
    cd user_service
    mix deps.get
    mix ecto.setup
    ```

3. Set up Wallet Service:
    ```bash
    cd ../wallet_service
    mix deps.get
    mix ecto.setup
    ```

4. Run RabbitMQ (if using Docker):
    ```bash
    docker run -d --hostname my-rabbit --name some-rabbit -p 5672:5672 -p 15672:15672 rabbitmq:3-management
    ```

### Running the Services

1. Start the User Service:
    ```bash
    cd user_service
    mix phx.server
    ```

2. Start the Wallet Service:
    ```bash
    cd ../wallet_service
    mix phx.server
    ```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
