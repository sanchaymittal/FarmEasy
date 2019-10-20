var FarmEasy = artifacts.require("./FarmEasy.sol");
var SafeMath = artifacts.require("./SafeMath.sol");
// var lib = artifacts.require("./lib.sol");
// var LendingProtocol = artifacts.require("./LendingProtocol.sol");

module.exports = function(deployer) {
  /* Deploy your contract here with the following command */
  // deployer.deploy(YourContract);
  // deployer.deploy(lib)
  deployer.deploy(SafeMath)
  deployer.link(SafeMath, FarmEasy)
  deployer.deploy(FarmEasy)
  // deployer.deploy(LendingProtocol)
};
