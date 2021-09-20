const DRepublic = artifacts.require('DRepublic.sol');
const NFTFactory = artifacts.require('NFTFactory.sol');
const NFTBlindBox = artifacts.require('NFTBlindBox.sol');
const NFTIncubator = artifacts.require('NFTIncubator.sol');

module.exports = async (deployer) => {
  await deployer.deploy(NFTFactory, 'DRepublic NFT', 'DRPC', 'https://www.cradles.io/dragontar/');
  await deployer.deploy(DRepublic, 'Wrapped ETH', 'WETH', '100000000000000000000000000', { gas: 5000000 });
  await deployer.deploy(NFTBlindBox, NFTFactory.address, DRepublic.address);
  await deployer.deploy(NFTIncubator, NFTFactory.address, NFTBlindBox.address);
};
