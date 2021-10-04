var HDWalletProvider = require("truffle-hdwallet-provider");

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();


module.exports = {
  networks: {
    development: {
      provider: function() {
        return new HDWalletProvider("maze cannon silk gossip recipe hazard train grit citizen paddle custom rain", "http://127.0.0.1:9545/", 0, 50);
      },
      network_id: '*',
      gas: 9999999
    },
    rinkeby: {
      provider: () => new HDWalletProvider(mnemonic, 'https://rinkeby.infura.io/v3/6014af9b9de84b028b1fb9ef2af4e901'),
      network_id: 4,       // Ropsten's id
      gas: 5500000,        // Ropsten has a lower block limit than mainnet
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      // skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
  },
  compilers: {
    solc: {
      version: "^0.4.24"
    }
  }
};