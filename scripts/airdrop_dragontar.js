const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const NFTFactoryABI = require('../build/contracts/NFTFactory.json');
// async
// const parse = require('csv-parse');
const parse = require('csv-parse/lib/sync');

const mnemonic = fs.readFileSync(".secret").toString().trim();
const bscLiveNetwork = "https://bsc-dataseed1.binance.org/";
const bscTestNetwork = "https://data-seed-prebsc-1-s1.binance.org:8545/";
// mainnet
// const caller = "0x3dcd25d7ccaf291cb36d5ca3df9b1468d2c97734";
// const nftFactoryAddress = "0x5492d2B7d886Cf6A3bE65439a2ca3AF0405Cd5b4";

// testnet
const caller = "0xA5225cBEE5052100Ec2D2D94aA6d258558073757";
const nftFactoryAddress = "0xa278641228CCfE148B9B6A0aeEE7A944093aa125";

async function main() {
    const provider = new HDWalletProvider(mnemonic, bscLiveNetwork);
    const web3 = new Web3(provider);

    const nftFactoryInstance = new web3.eth.Contract(
        NFTFactoryABI.abi,
        nftFactoryAddress,
        {gasLimit: "25000000"}
    );

    const dragontarContent = await fs.promises.readFile(__dirname + '/airdrop_dragontar_1.csv');
    const dragontars = parse(dragontarContent, {columns: true});
    console.log(dragontars)
    const recipientsContent = await fs.promises.readFile(__dirname + '/airdrop_whitelist.csv');
    const recipients = parse(recipientsContent, {columns: true});
    console.log(recipients)

    if (dragontars.length !== recipients.length) {
        console.log(dragontars.length, recipients.length);
        console.log("dragontars and recipients lenght not match!");
        return;
    }

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
    let attributes = [bg, body, dress, neck, eyes, tooth, mouth, decorates, hat, rare];

    let owners = [];
    let metadatas = [];
    let values = [];
    // i 从0递增到19
    let i = 0;
    for (i; i < dragontars.length; i++) {
        metadatas.push(dragontars[i].full_ID);
        values.push([parseInt(dragontars[i].bg), parseInt(dragontars[i].body), parseInt(dragontars[i].dress),
            parseInt(dragontars[i].neck), parseInt(dragontars[i].eyes), parseInt(dragontars[i].tooth),
            parseInt(dragontars[i].mouth), parseInt(dragontars[i].decorates), parseInt(dragontars[i].hat),
            parseInt(dragontars[i].rare)]);
        owners.push(recipients[i].recipient);

        // console.log("getHolderTokens=> owner: "+ recipients[i].recipient + "nft: " + await nftFactoryInstance.methods.getHolderTokens(recipients[i].recipient, 100, 0).call());
    }

    const ret = await nftFactoryInstance.methods
        .batchCreateNFT(owners, metadatas, attributes, values).send({from: caller});
    console.log("batchCreateNFT result: " + ret);

    // var parser = parse({columns: true}, function (err, records) {
    //     console.log(records);
    // });
    // fs.createReadStream(__dirname + '/airdrop_dragontar_1.csv').pipe(parser);

    // const user = "0x0888636179cB1783Ac2aaCE032521cc1129eB8f4";
    //
    // await nftFactoryInstance.methods
    //     .createNFT(user,
    //         "007005000000007001003000010",
    //         [bg, body, dress, neck, eyes, tooth, mouth, decorates, hat, rare],
    //         [7, 5, 0, 0, 7, 1, 3, 0, 10, 10]
    //     ).send({from: caller});
    //
    // console.log("nft factory getHolderTokens: ", await nftFactoryInstance.methods.getHolderTokens(user, 100, 0).call());

}

main();