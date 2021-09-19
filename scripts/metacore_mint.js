const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const metacoreABI = require('../build/contracts/metacore.json');
const legootABI = require('../build/contracts/legoot.json');
const erc20ABI = require('../build/contracts/erc20.json');

const mnemonic = fs.readFileSync('.secret').toString().trim();
const bscLiveNetwork = 'https://bsc-dataseed1.binance.org/';
const bscTestNetwork = 'https://data-seed-prebsc-1-s1.binance.org:8545/';
const rinkebyNetwork = 'https://rinkeby.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd';
const mumbaiNetwork = 'https://polygon-mumbai.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd';
const caller = '0xA5225cBEE5052100Ec2D2D94aA6d258558073757';

// rinkeby
// const metacoreAddress = "0x3B2deC58A96E5453c3CE6163C1789a615098996a";
// const legootAddress = "0x4Ad381B2f9eCEEBE7DE32fa7cDCD8b5E829aE6Cc";

// mumbai
const metacoreAddress = '0x267A3b0d36BD56561017b5dc3448b3cD47776Da9';
const legootAddress = '0x0F5ED2fbc6B4b43b51d57bc4016B4Cb83964F873';
const wethAddress = '0x1D190851714fA20af51715FdD2E5ee5CfAB6fC17';

async function main () {
  const provider = new HDWalletProvider(mnemonic, mumbaiNetwork);
  const web3 = new Web3(provider);

  const metacoreInstance = new web3.eth.Contract(
    metacoreABI.abi,
    metacoreAddress,
    { gasLimit: '5500000' },
  );

  const legootInstance = new web3.eth.Contract(
    legootABI.abi,
    legootAddress,
    { gasLimit: '5500000' },
  );

  const wethInstance = new web3.eth.Contract(
    erc20ABI.abi,
    wethAddress,
    { gasLimit: '5000000' },
  );

  const meatcoreId = 1;
  const legootId = 10;
  const legootId2 = 11;

  console.log('claim Metacore result: ',
    await metacoreInstance.methods.claim('DRepublic').send({ from: caller }));

  console.log('tokenURI Metacore: ',
    await metacoreInstance.methods.tokenURI(meatcoreId).call());

  console.log('approve eth result: ',
    await wethInstance.methods.approve(legootAddress, '30000000000000000').send({ from: caller }));
  console.log('claim Legoot result: ',
    await legootInstance.methods.claim(legootId).send({ from: caller }));

  console.log('tokenURI Legoot: ',
    await legootInstance.methods.tokenURI(legootId).call());

  console.log('approve eth result: ',
    await wethInstance.methods.approve(legootAddress, '30000000000000000').send({ from: caller }));
  console.log('claim Legoot2 result: ',
    await legootInstance.methods.claim(legootId2).send({ from: caller }));

  console.log('tokenURI Legoot2: ',
    await legootInstance.methods.tokenURI(legootId2).call());

  console.log('approve Legoot to Metacore contract result: ',
    await legootInstance.methods.approve(metacoreAddress, legootId).send({ from: caller }));

  console.log('combine result: ',
    await metacoreInstance.methods.combine(meatcoreId, legootAddress, legootId).send({ from: caller }));

  console.log('tokenURI Metacore: ',
    await metacoreInstance.methods.tokenURI(meatcoreId).call());

  console.log('approve Legoot2 to Metacore contract result: ',
    await legootInstance.methods.approve(metacoreAddress, legootId2).send({ from: caller }));

  console.log('combine Legoot2 result: ',
    await metacoreInstance.methods.combine(meatcoreId, legootAddress, legootId2).send({ from: caller }));

  console.log('tokenURI Metacore: ',
    await metacoreInstance.methods.tokenURI(meatcoreId).call());

  console.log('separateOne result: ',
    await metacoreInstance.methods.separateOne(meatcoreId, legootId).send({ from: caller }));

  console.log('tokenURI Metacore: ',
    await metacoreInstance.methods.tokenURI(meatcoreId).call());

  console.log('separateAll result: ',
    await metacoreInstance.methods.separate(meatcoreId).send({ from: caller }));

  console.log('tokenURI Metacore: ',
    await metacoreInstance.methods.tokenURI(meatcoreId).call());
}

main();
