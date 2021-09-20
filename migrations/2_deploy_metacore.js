
const Loot = artifacts.require('../contracts/Loot.sol');
const Metacore = artifacts.require('../contracts/Metacore.sol');
const Legoot = artifacts.require('../contracts/Legoot.sol');
const LootData = artifacts.require('../contracts/LootData.sol');

module.exports = async (deployer) => {
  await deployer.deploy(Loot);
  await deployer.deploy(LootData);
  await deployer.deploy(Legoot);
  await deployer.deploy(Metacore);
};
