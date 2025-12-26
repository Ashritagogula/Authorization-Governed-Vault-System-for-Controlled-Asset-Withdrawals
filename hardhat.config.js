require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.20",
  networks: {
    docker: {
      url: "http://local-blockchain:8545",
      chainId: 1337
    }
  }
};
