const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const NFTFactoryABI = require('../build/contracts/NFTFactory.json');
const ERC3664Generic = require('../build/contracts/ERC3664Generic.json');
const ATTACH_ROLE = Web3.utils.soliditySha3('ATTACH_ROLE');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";
const caller = "0x3dcd25d7ccaf291cb36d5ca3df9b1468d2c97734";

// testnet
const genericAttrAddress = "0x1E2Fbab5925098eC36D94b1Fb952fBb06603759d";
const nftFactoryAddress = "0xa278641228CCfE148B9B6A0aeEE7A944093aa125";

// mainnet
// const genericAttrAddress = "0xfc2aac9beD467A9B4AF18Ee6Eed85E8b0426877d";
// const nftFactoryAddress = "0x5492d2B7d886Cf6A3bE65439a2ca3AF0405Cd5b4";

async function main() {
    const provider = new HDWalletProvider(mnemonic, bscLiveNetwork);
    const web3 = new Web3(provider);

    const nftFactoryInstance = new web3.eth.Contract(
        NFTFactoryABI.abi,
        nftFactoryAddress,
        {gasLimit: "5500000"}
    );
    const genericAttrInstance = new web3.eth.Contract(
        ERC3664Generic.abi,
        genericAttrAddress,
        {gasLimit: "5500000"}
    );

    let result1 = await nftFactoryInstance.methods.registerAttribute(2, genericAttrAddress).send({from: caller});
    console.log("nft factory registerAttribute：", result1);

    console.log("nft factory  attributes: ", await nftFactoryInstance.methods.attributes(2).call());

    let result2 = await genericAttrInstance.methods.grantRole(ATTACH_ROLE, nftFactoryAddress).send({from: caller});
    console.log("generic attribute grantRole：", result2);

    // attributes
    const bg = 1;
    const body = 2;
    const dress = 3;
    const neck = 4;
    const eyes = 5;
    const tooth = 6;
    const mouth = 7;
    const decorates = 8;
    const hat = 9;
    const rare = 10;

    const result3 = await genericAttrInstance.methods.mintBatch(
        [bg, body, dress, neck, eyes, tooth, mouth, decorates, hat, rare],
        ["bg", "body", "dress", "neck", "eyes", "tooth", "mouth", "decorates", "hat", "rare"],
        ["bg", "body", "dress", "neck", "eyes", "tooth", "mouth", "decorates", "hat", "rare"],
        ["", "", "", "", "", "", "", "", "", ""]
    ).send({from: caller});

    console.log("generic attribute mintBatch：", result3);
}

main();