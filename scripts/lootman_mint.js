const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const parse = require('csv-parse/lib/sync');
const LootmanABI = require('../build/contracts/Lootman.json');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";
const rinkebyNetwork = "https://rinkeby.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd";
const caller = "0xA5225cBEE5052100Ec2D2D94aA6d258558073757";

// testnet
const lootmanAddress = "0x3346235a34b2C425f0Bbc935d8d6C8E24b3294D3";

// mainnet
// const lootmanAddress = "0x5492d2B7d886Cf6A3bE65439a2ca3AF0405Cd5b4";

async function main() {
    const provider = new HDWalletProvider(mnemonic, rinkebyNetwork);
    const web3 = new Web3(provider);

    const lootmanInstance = new web3.eth.Contract(
        LootmanABI.abi,
        lootmanAddress,
        {gasLimit: "5500000"}
    );

    // const context = await fs.promises.readFile(__dirname + '/lootman_first_names.csv');
    // const first_names = parse(context, {columns: true});

    // let names = [];
    // let i = 0;
    // let base = 0;
    // for (i + base; i < 100 + base; i++) {
    //     names.push(first_names[i].name);
    // }
    // console.log(names);

    const ret = await lootmanInstance.methods
        .claimName("Zhang").send({from: caller});

    console.log("claimName result: " + ret);

    console.log("tokenURI: " + await lootmanInstance.methods.tokenURI(1).call());

    // const ret2 = await lootmanInstance.methods
    //     .combine(1, [2]).send({from: caller});
    // console.log("combine result: " + ret2);

    // console.log("tokenURI: " + await lootmanInstance.methods.tokenURI(1).call());
    //
    // console.log("tokenURI: " + await lootmanInstance.methods.bundles(1,0).call());
    //
    // console.log("tokenURI: " + await lootmanInstance.methods.getSubMetadata(1).call());

}

main();