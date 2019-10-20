var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  migrations_directory: "./migrations",
  networks: {
    // development: {
    //   host: "localhost",
    //   port: 8545,
    //   network_id: "*" // Match any network id
    // },
    // ropsten: {
    //   provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/0bd3920316e94e9ca331d62dbe7b0eb6`),
    //   network_id: 3,       // Ropsten's id
    //   gas: 5500000,        // Ropsten has a lower block limit than mainnet
    //   confirmations: 2,    // # of confs to wait between deployments. (default: 0)
    //   timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
    //   skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    // }
    matic: {
      provider: function () {
        return new HDWalletProvider(
          "gesture rather obey video awake genuine patient base soon parrot upset lounge",
          "https://testnet2.matic.network"
        );
      },
      network_id: 8995,
      gas: 8000000,
      gasPrice: 0
    }
  }
};
