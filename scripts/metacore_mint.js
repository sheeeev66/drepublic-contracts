const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const metacoreABI = require('../build/contracts/metacore.json');
const slootABI = require('../build/contracts/sloot.json');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";
const rinkebyNetwork = "https://rinkeby.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd";
const caller = "0xA5225cBEE5052100Ec2D2D94aA6d258558073757";

// testnet
const metacoreAddress = "0x31576E52289061eCA5f983f36320537CD53C3b4F";

const slootAddress = "0xE429947bD53730e61c5947C0cAb230aB4747F524";

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

    const slootInstance = new web3.eth.Contract(
        slootABI.abi,
        slootAddress,
        {gasLimit: "5500000"}
    );

    const meatcoreId = 1;
    const slootId = 3;

    const ret1 = await metacoreInstance.methods.claim("DRepublic").send({from: caller});

    console.log("claim Metacore result: " + ret1);

    console.log("tokenURI Metacore: " + await metacoreInstance.methods.tokenURI(meatcoreId).call());

    const ret2 = await slootInstance.methods.claim(slootId).send({from: caller});

    console.log("claim SLoot result: " + ret2);

    console.log("tokenURI SLoot: " + await slootInstance.methods.tokenURI(slootId).call());

    const ret3 = await slootInstance.methods.approve(metacoreAddress, slootId).send({from: caller});
    console.log("approve SLoot to Metacore contract result: " + ret3);

    const ret4 = await metacoreInstance.methods.combine(meatcoreId, [slootAddress], [slootId]).send({from: caller});
    console.log("combine result: " + ret4);

    console.log("tokenURI Metacore: " + await metacoreInstance.methods.tokenURI(meatcoreId).call());

    // console.log("tokenAttributes SLoot: " + await slootInstance.methods.tokenAttributes(slootId).call());
    //
    // const ret5 = await metacoreInstance.methods.separate(1).send({from: caller});
    // console.log("separate result: " + ret5);

    // console.log("tokenURI: " + await metacoreInstance.methods.bundles(1,0).call());
    //
    // console.log("tokenURI: " + await metacoreInstance.methods.getSubMetadata(1).call());
}

main();