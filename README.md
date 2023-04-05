# TrueElysium

TrueElysium is a Swift app that serves as a node of the coin shuffle protocol. To run this app, you will first need to compile the Rust bridge located at `git@github.com:coin-shuffle/crypto-bridge.git` and put the resulting `libra_crypto.a` files into the main directory of this project.

## Getting Started

To get started with TrueElysium, follow these steps:

1. Clone this repository onto your local machine.
2. Clone the `crypto-bridge` repository onto your local machine as well.
3. Follow the instructions in the `crypto-bridge` repository's README.md file to compile the Rust bridge.
4. Copy the resulting `libra_crypto.a` file into the main directory of the TrueElysium repository.
5. Open the TrueElysium Xcode project in Xcode.
6. Build and run the project.

## Usage

Once TrueElysium is running, it will serve as a node of the coin shuffle protocol. You can configure the app's behavior by editing the relevant settings in the `Config.yaml` file.

## Contributing

If you would like to contribute to TrueElysium, please follow these steps:

1. Fork this repository onto your own GitHub account.
2. Create a new branch for your changes.
3. Make your changes and commit them.
4. Push your branch to your fork of the repository.
5. Open a pull request from your fork's branch to the `main` branch of this repository.

## License

TrueElysium is released under the Apache-2 License. See `LICENSE.md` for details.
