const truffleAssert = require('truffle-assertions');
const ATTACH_ROLE = web3.utils.soliditySha3('ATTACH_ROLE');

const ERC3664Generic = artifacts.require("../contracts/ERC3664/presets/ERC3664Generic.sol");
const NFTFactory = artifacts.require("../contracts/NFTFactory.sol");

const toBN = web3.utils.toBN;

let baseUri = 'https://www.cradles.io/dragontar/';

contract("NFTFactory", (accounts) => {
    const owner = accounts[0];
    const userA = accounts[1];
    const userB = accounts[2];

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

    let nft;
    let genericAttr;

    before(async () => {
        nft = await NFTFactory.new(
            "DRepublic NFT", "DRPC",
            baseUri
        );

        genericAttr = await ERC3664Generic.new();
        await genericAttr.grantRole(ATTACH_ROLE, nft.address);

        await nft.registerAttribute(2, genericAttr.address);

        await genericAttr.mintBatch(
            [bg, body, dress, neck, eyes, tooth, mouth, decorates, hat, rare],
            ["bg", "body", "dress", "neck", "eyes", "tooth", "mouth", "decorates", "hat", "rare"],
            ["bg", "body", "dress", "neck", "eyes", "tooth", "mouth", "decorates", "hat", "rare"],
            ["", "", "", "", "", "", "", "", "", ""]
        );
    });

    describe('1. premint NFTs only contract owner', () => {
        it('batch create NFTs', async () => {
            await nft.batchCreateNFT(
                [userA, userA],
                ["001002", "007008"],
                [bg, body, dress, neck, eyes, tooth, mouth, decorates, hat, rare],
                [[100, 101, 102, 103, 104, 105, 106, 107, 108, 109],
                    [110, 111, 112, 113, 114, 115, 116, 117, 118, 119]]
            );
            // genesis nft
            console.log("uri: ", await nft.uri(0));
            console.log("uri: ", await nft.uri(1));

            const amount = await nft.balanceOf(
                userA,
                0
            );
            assert.isOk(amount.eq(toBN(1)));

            let val = await genericAttr.balanceOf(0, bg);
            assert.isOk(val.eq(toBN(100)));

            let ownedNfts = await nft.getHolderTokens(userA);
            console.log("owner nfts: ", ownedNfts);
        });
    });
});
