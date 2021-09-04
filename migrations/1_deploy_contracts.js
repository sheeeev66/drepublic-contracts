// const Arrays = artifacts.require("../contracts/utils/Arrays.sol");
// const ERC3664Generic = artifacts.require("../contracts/ERC3664/presets/ERC3664Generic.sol");
// const DRepublic = artifacts.require("../contracts/DRepublic.sol");
// const NFTFactory = artifacts.require("../contracts/NFTFactory.sol");
// const NFTBlindBox = artifacts.require("../contracts/NFTBlindBox.sol");
// const NFTIncubator = artifacts.require("../contracts/NFTIncubator.sol");
const Lootman = artifacts.require("../contracts/Lootman.sol");

module.exports = async (deployer) => {
    await deployer.deploy(Lootman);

    // await deployer.deploy(ERC3664Generic);
    // await deployer.deploy(NFTFactory, "DRepublic NFT", "DRPC", "https://www.cradles.io/dragontar/");
    // await deployer.deploy(DRepublic, "Tether USD", "USDT", '100000000000000000000000000', {gas: 5000000});
    // await deployer.deploy(NFTBlindBox, NFTFactory.address, DRepublic.address);
    // await deployer.deploy(NFTIncubator, NFTFactory.address, NFTBlindBox.address);
    // await deployer.link(Arrays, GenericAttribute);
};
