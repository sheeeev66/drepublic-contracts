const truffleAssert = require('truffle-assertions');

const DRepublic = artifacts.require("../contracts/DRepublic.sol");
const NFTFactory = artifacts.require("../contracts/NFTFactory.sol");
const NFTBlindBox = artifacts.require("../contracts/NFTBlindBox.sol");

const toBN = web3.utils.toBN;

contract("NFTBlindBox", (accounts) => {
	const owner = accounts[0];
	const userA = accounts[1];

	let usdt;
	let nft;
	let box;

	before(async () => {
		usdt = await DRepublic.new("Tether USD", "USDT", '100000000000000000000000');
		nft = await NFTFactory.new(
			"DRepublic NFT", "DRPC",
			"https://drepublic.io/api/nfts/{id}"
		);
		box = await NFTBlindBox.new(nft.address, usdt.address);
		await box.setPrices(1, toBN(10), toBN(20), toBN(30));
	});

	describe('1. premint NFTs only contract owner', () => {
		it('batch create NFTs to NFTBlindBox ', async () => {
			await nft.batchCreate(
				[box.address],
				[toBN(123456789123456789)],
				[1],
				["https://drepublic.io/api/nfts/{id}"],
				"0x0"
			);

			const amount = await nft.balanceOf(
				box.address,
				toBN(123456789123456789)
			);
			assert.isOk(amount.eq(toBN(1)));
		});

		it('upload NFTs to NFTBlindBox market', async () => {
			await box.uploadNfts(
				1,
				[toBN(123456789123456789)]
			);

			const nl = await box.getNFTLength(
				1
			);
			assert.isOk(nl.eq(toBN(1)));
		});
	});

	describe('2. buy NFTBlindBox', () => {
		it('approve usdt to NFTBlindBox', async () => {
			await usdt.transfer(userA, toBN(100));

			const price = toBN(30);
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
			const pay = toBN(30);
			await box.openBox(
				usdt.address,
				pay,
				1,
				{from: userA}
			);

			const amount = await nft.balanceOf(
				userA,
				toBN(123456789123456789)
			);
			assert.isOk(amount.eq(toBN(1)));
			const nl = await box.getNFTLength(
				1
			);
			assert.isOk(nl.eq(toBN(0)));
		});
	});
});
