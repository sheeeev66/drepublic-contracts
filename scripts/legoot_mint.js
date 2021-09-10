const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const legootABI = require('../build/contracts/legoot.json');
const lootdataABI = require('../build/contracts/LootData.json');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";
const rinkebyNetwork = "https://rinkeby.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd";
const caller = "0xA5225cBEE5052100Ec2D2D94aA6d258558073757";

// const lootdataAddress = "0x283D93B97b0923c833374c6401eF74B837B64cAf";

const legootAddress = "0xb41b3b6a286718f5c319c9e9ade223f9ee060c54";

// mainnet
// const legootAddress = "0xe98d61D06078993c0cB59Ad3021e1c782dBEe26A";

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

    const lootId = 8001;

    // const ret1 = await lootInstance.methods.claim(lootId).send({from: caller});
    //
    // console.log("claim Legoot result: " + ret1);

    console.log("tokenURI Legoot: " + await lootInstance.methods.tokenURI(lootId).call());

    // const ret3 = await slootInstance.methods.approve(metacoreAddress, slootId).send({from: caller});
    // console.log("approve SLoot to Metacore contract result: " + ret3);
    //
    // const ret4 = await metacoreInstance.methods.combine(meatcoreId, [legootAddress], [slootId]).send({from: caller});
    // console.log("combine result: " + ret4);
    //
    // console.log("tokenURI Metacore: " + await metacoreInstance.methods.tokenURI(meatcoreId).call());

    // console.log("tokenAttributes Legoot: " + await lootInstance.methods.getAttributes(lootId).call());

    //
    // const ret5 = await metacoreInstance.methods.separate(1).send({from: caller});
    // console.log("separate result: " + ret5);
    //
    // console.log("tokenURI: " + await metacoreInstance.methods.getSubMetadata(1).call());
}

main();