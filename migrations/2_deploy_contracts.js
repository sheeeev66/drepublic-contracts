const DRepublic = artifacts.require("../contracts/DRepublic.sol");
const NFTFactory = artifacts.require("../contracts/NFTFactory.sol");
const NFTBlindBox = artifacts.require("../contracts/NFTBlindBox.sol");

// https://nfts-api.origin-games.io/api/nfts/{id}
module.exports = async (deployer) => {
	await deployer.deploy(DRepublic, "Tether USD", "USDT");

	await deployer.deploy(NFTFactory, "DRepublic NFT", "DRPC", "https://drepublic.io/api/nfts/{id}");
	await deployer.deploy(NFTBlindBox, NFTFactory.address, DRepublic.address);
};
