const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const erc20ABI = require('../build/contracts/erc20.json');
const legootABI = require('../build/contracts/legoot.json');
const lootdataABI = require('../build/contracts/LootData.json');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const caller = "0xA5225cBEE5052100Ec2D2D94aA6d258558073757";

// networks
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";
const rinkebyNetwork = "https://rinkeby.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd";
const mumbaiNetwork = "https://polygon-mumbai.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd";
const polygonNetwork = "https://heimdall.api.matic.network";

// contracts
// rinkeby
// const lootdataAddress = "0x283D93B97b0923c833374c6401eF74B837B64cAf";
// const legootAddress = "0x4Ad381B2f9eCEEBE7DE32fa7cDCD8b5E829aE6Cc";

// mumbai
const lootdataAddress = "0x4CF659eA4CB55502C5F8225172EEdc72A9542733";
const legootAddress = "0x0F5ED2fbc6B4b43b51d57bc4016B4Cb83964F873";
const wethAddress = "0x1D190851714fA20af51715FdD2E5ee5CfAB6fC17";


async function main() {
    const provider = new HDWalletProvider(mnemonic, mumbaiNetwork);
    const web3 = new Web3(provider);

    const lootInstance = new web3.eth.Contract(
        legootABI.abi,
        legootAddress,
        {gasLimit: "8000000"}
    );

    // const lootdataInstance = new web3.eth.Contract(
    //     lootdataABI.abi,
    //     lootdataAddress,
    //     {gasLimit: "5000000"}
    // );

    const wethInstance = new web3.eth.Contract(
        erc20ABI.abi,
        wethAddress,
        {gasLimit: "5000000"}
    );

    const lootId = 1;

    console.log("approve eth result: ", await wethInstance.methods.approve(legootAddress, "30000000000000000").send({from: caller}));

    console.log("claim Legoot result: ", await lootInstance.methods.claim(lootId).send({from: caller}));

    console.log("tokenURI Legoot: ", await lootInstance.methods.tokenURI(lootId).call());

    console.log("Legoot separateOne result: ", await lootInstance.methods.separateOne(lootId, 8001 + (lootId - 1) * 8).send({from: caller}));

    console.log("tokenURI: ", await lootInstance.methods.tokenURI(lootId).call());

    console.log("Legoot separateAll result: ", await lootInstance.methods.separate(lootId).send({from: caller}));

    console.log("tokenURI: ", await lootInstance.methods.tokenURI(lootId).call());

    console.log("combine result: ", await lootInstance.methods.combine(lootId, [8001 + (lootId - 1) * 8]).send({from: caller}));

    console.log("tokenURI: ", await lootInstance.methods.tokenURI(lootId).call());
}

main();