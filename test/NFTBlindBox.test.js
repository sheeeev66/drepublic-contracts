const truffleAssert = require('truffle-assertions');
const {expect} = require('chai');

const DRepublic = artifacts.require("../contracts/DRepublic.sol");
const NFTFactory = artifacts.require("../contracts/NFTFactory.sol");
const NFTBlindBoxTest = artifacts.require("../contracts/NFTBlindBox.sol");
const NFTIncubator = artifacts.require("../contracts/NFTIncubator.sol");

const toBN = web3.utils.toBN;

let baseUri = 'https://www.cradles.io/dragontar/';

contract("NFTBlindBox", (accounts) => {
	const owner = accounts[0];
	const userA = accounts[1];
	const userB = accounts[2];

	let nftA = 1000;
	let nftB = 1001;
	let incubatorId = 2000;

	let usdt;
	let nft;
	let box;
	let incubator;

	before(async () => {
		usdt = await DRepublic.new("Tether USD", "USDT", '100000000000000000000000');
		await usdt.transfer(userA, toBN(100));
		await usdt.transfer(userB, toBN(100));

		nft = await NFTFactory.new(
			"DRepublic NFT", "DRPC",
			"https://drepublic.io/api/nfts/{id}"
		);
		box = await NFTBlindBoxTest.new(nft.address, usdt.address);
		incubator = await NFTIncubator.new(nft.address, box.address);
		await box.setPrices(1, toBN(10), toBN(20));
		await box.setIncubator(incubator.address);
		await incubator.createSharedIncubators([incubatorId]);
		await nft.createNFT(userB, nftB);
	});

	describe('1. premint NFTs only contract owner', () => {
		it('batch create NFTs to NFTBlindBox ', async () => {
			await nft.batchCreateNFT(
				[box.address],
				[nftA]
			);

			const amount = await nft.balanceOf(
				box.address,
				nftA
			);
			assert.isOk(amount.eq(toBN(1)));
		});

		it('upload NFTs to NFTBlindBox market', async () => {
			await box.uploadNFTs(
				1,
				[nftA]
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
				nftA
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
			);
			await box.uploadNFTs(
				2,
				[1100, 1101]
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
				nftA,
				{from: userA}
			);
			// console.log("incubator: ", await incubator.incubators(incubatorId));
		});

		it('NFT breed', async () => {
			const receipt = await incubator.breed(incubatorId, nftB, {from: userB});
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
