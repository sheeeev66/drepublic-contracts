const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const metacoreABI = require('../build/contracts/metacore.json');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";
const rinkebyNetwork = "https://rinkeby.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd";
const caller = "0xA5225cBEE5052100Ec2D2D94aA6d258558073757";

// testnet
const metacoreAddress = "0x6F198ffEAc4C2286AbFE6C85733a814d33176375";

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

    const ret1 = await metacoreInstance.methods
        .claim("hello").send({from: caller});

    console.log("claimName result: " + ret1);

    console.log("tokenURI: " + await metacoreInstance.methods.tokenURI(1).call());

    const ret2 = await metacoreInstance.methods
        .claim("world").send({from: caller});

    console.log("claimName result: " + ret2);

    console.log("tokenURI: " + await metacoreInstance.methods.tokenURI(2).call());

    const ret3 = await metacoreInstance.methods
        .combine(1, [2]).send({from: caller});
    console.log("combine result: " + ret3);

    console.log("tokenURI: " + await metacoreInstance.methods.tokenURI(2).call());
    //
    // console.log("tokenURI: " + await metacoreInstance.methods.bundles(1,0).call());
    //
    // console.log("tokenURI: " + await metacoreInstance.methods.getSubMetadata(1).call());
}

main();