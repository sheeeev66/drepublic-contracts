const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const NFTFactoryABI = require('../build/contracts/NFTFactory.json');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";
const caller = "0xA5225cBEE5052100Ec2D2D94aA6d258558073757";

const nftFactoryAddress = "0xa278641228CCfE148B9B6A0aeEE7A944093aa125";

async function main() {
    const provider = new HDWalletProvider(mnemonic, bscTestNetwork);
    const web3 = new Web3(provider);

    const nftFactoryInstance = new web3.eth.Contract(
        NFTFactoryABI.abi,
        nftFactoryAddress,
        {gasLimit: "5500000"}
    );

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
    
    const result1 = await nftFactoryInstance.methods
        .createNFT("0x0A559eD20fD86DC38A7aF82E7EdE91aE9b43b5f5",
            "007005000000007001003000010",
            [bg, body, dress, neck, eyes, tooth, mouth, decorates, hat, rare],
            [7, 5, 0, 0, 7, 1, 3, 0, 10, 10]
        ).send({from: caller});
    console.log("result: " + result1);

    // const result2 = await nftFactoryInstance.methods
    //     .batchCreateNFT(["0x0A559eD20fD86DC38A7aF82E7EdE91aE9b43b5f5", "0x6e1F35c11eACcc4D81B67c50827c3674593C8D23"],
    //         ["0011100001111000001111", "110001000100010001"]).send();
    // console.log("result: " + result);
}

main();