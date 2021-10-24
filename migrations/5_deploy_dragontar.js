const DragontarData = artifacts.require('DragontarData.sol');
const Dragontar = artifacts.require('Dragontar.sol');

module.exports = async (deployer) => {
  // await deployer.deploy(DragontarData);
  await deployer.deploy(Dragontar);
};
