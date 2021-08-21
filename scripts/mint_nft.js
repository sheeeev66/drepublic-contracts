const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const NFTFactoryABI = require('build/contracts/NFTFactory.json');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";

const nftFactoryAddress = "";

async function main() {
    const provider = new HDWalletProvider(mnemonic, bscTestNetwork);
    const web3 = new Web3(provider);

    const nftFactoryInstance = new web3.eth.Contract(
        NFTFactoryABI,
        nftFactoryAddress,
        {gasLimit: "5500000"}
    );

    const result1 = await nftFactoryInstance.methods
        .createNFT("0x0A559eD20fD86DC38A7aF82E7EdE91aE9b43b5f5",
            "0011100001111000001111").send();
    console.log("result: " + result);

    const result2 = await nftFactoryInstance.methods
        .batchCreateNFT(["0x0A559eD20fD86DC38A7aF82E7EdE91aE9b43b5f5", "0x6e1F35c11eACcc4D81B67c50827c3674593C8D23"],
            ["0011100001111000001111", "110001000100010001"]).send();
    console.log("result: " + result);
}

main();