const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const metacoreABI = require('../build/contracts/metacore.json');
const legootABI = require('../build/contracts/legoot.json');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";
const rinkebyNetwork = "https://rinkeby.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd";
const caller = "0xA5225cBEE5052100Ec2D2D94aA6d258558073757";

// testnet
const metacoreAddress = "0xC37b106c106Ae7A177f43fe08aABEC447E510E23";

const legootAddress = "0xdc2aF6a69A3D3d5F90120FBA1fea87fcf2A4990D";

// mainnet
// const metacoreAddress = "0xe98d61D06078993c0cB59Ad3021e1c782dBEe26A";

async function main() {
    const provider = new HDWalletProvider(mnemonic, rinkebyNetwork);
    const web3 = new Web3(provider);

    const metacoreInstance = new web3.eth.Contract(
        metacoreABI.abi,
        metacoreAddress,
        {gasLimit: "5500000"}
    );

    const legootInstance = new web3.eth.Contract(
        legootABI.abi,
        legootAddress,
        {gasLimit: "5500000"}
    );

    const meatcoreId = 2;
    const legootId = 20;
    const legootId2 = 21;

    console.log("claim Metacore result: ", await metacoreInstance.methods.claim("DRepublic").send({from: caller}));

    console.log("tokenURI Metacore: ", await metacoreInstance.methods.tokenURI(meatcoreId).call());

    console.log("claim Legoot result: ", await legootInstance.methods.claim(legootId).send({from: caller}));

    console.log("tokenURI Legoot: ", await legootInstance.methods.tokenURI(legootId).call());

    console.log("claim Legoot2 result: ", await legootInstance.methods.claim(legootId2).send({from: caller}));

    console.log("tokenURI Legoot2: ", await legootInstance.methods.tokenURI(legootId2).call());

    console.log("approve Legoot to Metacore contract result: ", await legootInstance.methods.approve(metacoreAddress, legootId).send({from: caller}));

    console.log("combine result: ", await metacoreInstance.methods.combine(meatcoreId, legootAddress, legootId).send({from: caller}));

    console.log("tokenURI Metacore: " + await metacoreInstance.methods.tokenURI(meatcoreId).call());

    console.log("approve Legoot2 to Metacore contract result: ", await legootInstance.methods.approve(metacoreAddress, legootId2).send({from: caller}));

    console.log("combine Legoot2 result: ", await metacoreInstance.methods.combine(meatcoreId, legootAddress, legootId2).send({from: caller}));

    console.log("tokenURI Metacore: " + await metacoreInstance.methods.tokenURI(meatcoreId).call());

    console.log("separateOne result: ", await metacoreInstance.methods.separateOne(meatcoreId, legootId).send({from: caller}));

    console.log("tokenURI Metacore: " + await metacoreInstance.methods.tokenURI(meatcoreId).call());

    console.log("separateAll result: ", await metacoreInstance.methods.separate(meatcoreId).send({from: caller}));

    console.log("tokenURI Metacore: " + await metacoreInstance.methods.tokenURI(meatcoreId).call());
}

main();