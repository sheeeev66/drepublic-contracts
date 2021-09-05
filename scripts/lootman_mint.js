const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const LootmanABI = require('../build/contracts/Lootman.json');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";
const rinkebyNetwork = "https://rinkeby.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd";
const caller = "0xA5225cBEE5052100Ec2D2D94aA6d258558073757";

// testnet
const lootmanAddress = "0x918225F5D0a8A39B1d3A176610107F8Dd158E58d";

// mainnet
// const lootmanAddress = "0xe98d61D06078993c0cB59Ad3021e1c782dBEe26A";

async function main() {
    const provider = new HDWalletProvider(mnemonic, rinkebyNetwork);
    const web3 = new Web3(provider);

    const lootmanInstance = new web3.eth.Contract(
        LootmanABI.abi,
        lootmanAddress,
        {gasLimit: "5500000"}
    );

    const ret1 = await lootmanInstance.methods
        .claimName("hello").send({from: caller});

    console.log("claimName result: " + ret1);

    console.log("tokenURI: " + await lootmanInstance.methods.tokenURI(1).call());

    const ret2 = await lootmanInstance.methods
        .claimName("world").send({from: caller});

    console.log("claimName result: " + ret2);

    console.log("tokenURI: " + await lootmanInstance.methods.tokenURI(2).call());

    const ret3 = await lootmanInstance.methods
        .combine(1, [2]).send({from: caller});
    console.log("combine result: " + ret3);

    console.log("tokenURI: " + await lootmanInstance.methods.tokenURI(2).call());
    //
    // console.log("tokenURI: " + await lootmanInstance.methods.bundles(1,0).call());
    //
    // console.log("tokenURI: " + await lootmanInstance.methods.getSubMetadata(1).call());
}

main();