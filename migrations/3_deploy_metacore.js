const Loot = artifacts.require('Loot.sol');
const Metacore = artifacts.require('Metacore.sol');
const Legoot = artifacts.require('Legoot.sol');
const LootData = artifacts.require('LootData.sol');

module.exports = async (deployer) => {
  await deployer.deploy(Loot);
  await deployer.deploy(LootData);
  await deployer.deploy(Legoot);
  await deployer.deploy(Metacore);
};
