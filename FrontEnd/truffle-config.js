const path = require("path");
var HDWalletProvider = require("truffle-hdwallet-provider");
data = "3BE52D87BE2A210E768FB420590222482AB61305B406B9F7D630AD3A95D71331"
module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "src/contracts"),
  networks: {
    develop: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*',
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(data, "https://ropsten.infura.io/v3/46770654a6f6479489228ef81a5b797a")
      },
      network_id: 3
    },
    kovan: {
      provider: function() {
        return new HDWalletProvider(data, "https://kovan.infura.io/v3/46770654a6f6479489228ef81a5b797a")
      },
      network_id: 42
    },

  }
};
