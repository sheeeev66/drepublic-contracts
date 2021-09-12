const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const legootABI = require('../build/contracts/legoot.json');
const lootdataABI = require('../build/contracts/LootData.json');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const caller = "0xA5225cBEE5052100Ec2D2D94aA6d258558073757";

// networks
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";
const rinkebyNetwork = "https://rinkeby.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd";
const mumbaiNetwork = "https://heimdall.api.matic.today";
const polygonNetwork = "https://heimdall.api.matic.network";

// contracts
// rinkeby
// const lootdataAddress = "0x283D93B97b0923c833374c6401eF74B837B64cAf";
const legootAddress = "0x97f74f8668D42E3b4fB08fE4c9aA23dAE4511681";

// mumbai
// const lootdataAddress = "0x283D93B97b0923c833374c6401eF74B837B64cAf";
// const legootAddress = "0x94c7c0d6B784E781187b189050eb6061E8Fb7Ae0";


async function main() {
    const provider = new HDWalletProvider(mnemonic, rinkebyNetwork);
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

    const lootId = 2;

    console.log("claim Legoot result: ", await lootInstance.methods.claim(lootId).send({from: caller, value: 3 * 10000000000000000}));

    console.log("tokenURI Legoot: ", await lootInstance.methods.tokenURI(lootId).call());

    console.log("Legoot separateOne result: ", await lootInstance.methods.separateOne(lootId, 8001 + (lootId - 1) * 8).send({from: caller}));

    console.log("tokenURI: ", await lootInstance.methods.tokenURI(lootId).call());

    console.log("Legoot separateAll result: ", await lootInstance.methods.separate(lootId).send({from: caller}));

    console.log("tokenURI: ", await lootInstance.methods.tokenURI(lootId).call());

    console.log("combine result: ", await lootInstance.methods.combine(lootId, [8001 + (lootId - 1) * 8]).send({from: caller}));

    console.log("tokenURI: ", await lootInstance.methods.tokenURI(lootId).call());
}

main();