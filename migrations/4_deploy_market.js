const ERC1155Tradable = artifacts.require('ERC1155Tradable.sol');
const NFTMarket = artifacts.require('NFTMarket.sol');

module.exports = async (deployer) => {
  await deployer.deploy(ERC1155Tradable, 'Cradles NFTs', 'Consumables', 'https://www.cradles.io/assets/');
  await deployer.deploy(NFTMarket);
};
