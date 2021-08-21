const truffleAssert = require('truffle-assertions');
const {expect} = require('chai');
const {to} = require("truffle/build/557.bundled");

const Arrays = artifacts.require("../contracts/utils/Arrays.sol");
const GenericAttribute = artifacts.require("../contracts/EIP3664/GenericAttribute.sol");
const DRepublic = artifacts.require("../contracts/DRepublic.sol");
const NFTFactory = artifacts.require("../contracts/NFTFactory.sol");
const NFTBlindBox = artifacts.require("../contracts/NFTBlindBox.sol");
const NFTIncubator = artifacts.require("../contracts/NFTIncubator.sol");

const toBN = web3.utils.toBN;

let baseUri = 'https://www.cradles.io/dragontar/';

contract("NFTBlindBox", (accounts) => {
    const owner = accounts[0];
    const userA = accounts[1];
    const userB = accounts[2];

    const nftMetadata = 123456789;
    const incubatorId = 2000;

    const nftIndexB = 0;
    const nftIndexA = 1;

    // attributes
    const bg = 3000;
    const skin = 3001;
    // const horn = 3002;
    // const eyes = 3003;
    // const body = 3004;
    // const decorate = 3005;
    // const rare = 3006;

    let usdt;
    let nft;
    let box;
    let incubator;
    let genericAttr;

    before(async () => {
        usdt = await DRepublic.new("Tether USD", "USDT", '100000000000000000000000');
        await usdt.transfer(userA, toBN(100));
        await usdt.transfer(userB, toBN(100));

        nft = await NFTFactory.new(
            "DRepublic NFT", "DRPC",
            baseUri
        );
        box = await NFTBlindBox.new(nft.address, usdt.address);
        incubator = await NFTIncubator.new(nft.address, box.address);
        await box.setPrices(1, toBN(10), toBN(20));
        await box.setIncubator(incubator.address);
        await incubator.createSharedIncubators([incubatorId]);

        GenericAttribute.link(Arrays);
        genericAttr = await GenericAttribute.new();
        await nft.setGenericAttr(genericAttr.address);

        await genericAttr.changeOperator(nft.address);
        await genericAttr.create(
            bg,
            "background",
            "background attribute",
            18,
            {from: owner}
        );
        await genericAttr.create(
            skin,
            "skin",
            "skin attribute",
            18
        );

        await nft.createNFT(userB, nftMetadata, [bg, skin], [1, 2]);
        // first nft
        console.log("uri: ", await nft.uri(0));
        const amount = await nft.balanceOf(
            userB,
            nftIndexB
        );
        assert.isOk(amount.eq(toBN(1)));
    });

    describe('1. premint NFTs only contract owner', () => {
        it('batch create NFTs to NFTBlindBox ', async () => {
            await nft.batchCreateNFT(
                [box.address],
                [nftMetadata],
                [[bg, skin], [bg, skin]],
                [[1, 2], [1, 2]]
            );
            console.log("uri: ", await nft.uri(1));

            const amount = await nft.balanceOf(
                box.address,
                1
            );
            assert.isOk(amount.eq(toBN(1)));

            assert.equal(
                await genericAttr.attributeValue(1, bg),
                1
            );
        });

        it('upload NFTs to NFTBlindBox market', async () => {
            await box.uploadNFTs(
                1,
                [1]
            );

            const nl = await box.getNFTLength(
                1
            );
            assert.isOk(nl.eq(toBN(1)));
        });
    });

    describe('2. buy NFTBlindBox', () => {
        it('approve usdt to NFTBlindBox', async () => {
            const price = toBN(20);
            await usdt.approve(box.address, price, {from: userA});

            const amount = await usdt.allowance(
                userA,
                box.address
            );
            assert.isOk(price.eq(amount));
        });
    });

    describe('3. open NFTBlindBox', () => {
        it('transfer NFT to buyer', async () => {
            const pay = toBN(20);
            await box.openBox(
                usdt.address,
                pay,
                1,
                {from: userA}
            );

            const amount = await nft.balanceOf(
                userA,
                1
            );
            assert.isOk(amount.eq(toBN(1)));
            const nl = await box.getNFTLength(
                1
            );
            assert.isOk(nl.eq(toBN(0)));
        });
    });

    describe('4. NFT breeding', () => {
        it('mint lv2 nft', async () => {
            await nft.batchCreateNFT(
                [box.address, box.address],
                [1100, 1101],
                [[bg, skin], [bg, skin]],
                [[1, 2], [1, 2]]
            );
            await box.uploadNFTs(
                2,
                [2, 3]
            );
        });

        it('NFT approve to incubator', async () => {
            await nft.setApprovalForAll(
                incubator.address,
                true,
                {from: userA}
            );
            // TODO
            await nft.setApprovalForAll(
                incubator.address,
                true,
                {from: userB}
            );
        });

        it('NFT store', async () => {
            await incubator.store(
                incubatorId,
                nftIndexA,
                {from: userA}
            );
            // console.log("incubator: ", await incubator.incubators(incubatorId));
        });

        it('NFT breed', async () => {
            const receipt = await incubator.breed(incubatorId, nftIndexB, {from: userB});
            // truffleAssert.eventNotEmitted(
            // 	receipt,
            // 	'IncubatorBreed',
            // 	{
            // 		from: userB,
            // 		incubatorId: incubatorId,
            // 		first: 1000,
            // 		second: 1001
            // 	}
            // );
        });
    });
});
