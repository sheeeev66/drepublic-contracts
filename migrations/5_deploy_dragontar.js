const ERC721AutoId = artifacts.require('ERC721AutoId.sol');
const DragontarData = artifacts.require('DragontarData.sol');
const Dragontar = artifacts.require('Dragontar.sol');

module.exports = async (deployer) => {
  await deployer.deploy(DragontarData);
  await deployer.deploy(ERC721AutoId, 'Dragontar Attributes Token', 'DAT', '');
  await deployer.deploy(Dragontar);
};
