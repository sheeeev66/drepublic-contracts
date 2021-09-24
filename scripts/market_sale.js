const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const erc1155ABI = require('../build/contracts/ERC1155Tradable.json');
const marketABI = require('../build/contracts/NFTMarket.json');

const mnemonic = fs.readFileSync('.secret').toString().trim();
const caller = '0xA5225cBEE5052100Ec2D2D94aA6d258558073757';

// networks
const bscLiveNetwork = 'https://bsc-dataseed1.binance.org/';
const bscTestNetwork = 'https://data-seed-prebsc-1-s1.binance.org:8545/';
const rinkebyNetwork = 'https://rinkeby.infura.io/v3/8355dcd582884501bae9d5bda7ba8ecd';

// contracts
// bsc
const nftAddress = '0x03158D5EdE7c482994d593b52eCCc92194907DbC';
const marketAddress = '0x152f86737499fE44f47cfdC44eea765cB8e0eF9c';

async function main () {
  const provider = new HDWalletProvider(mnemonic, bscTestNetwork);
  const web3 = new Web3(provider);

  const nftInstance = new web3.eth.Contract(
    erc1155ABI.abi,
    nftAddress,
    { gasLimit: '10000000' },
  );

  const marketInstance = new web3.eth.Contract(
    marketABI.abi,
    marketAddress,
    { gasLimit: '5000000' },
  );

  const tokenId = 0;

  // initial contracts
  console.log('create Nautilus Ammonite Fossil: ',
    await nftInstance.methods.create(caller, tokenId + 1, 0, 'www.cradles.io/assets/ammonites/nautilus').send({ from: caller }));

  console.log('create Shell Ammonite Fossil: ',
    await nftInstance.methods.create(caller, tokenId + 2, 0, 'www.cradles.io/assets/ammonites/shell').send({ from: caller }));

  console.log('create Spiral Shell Ammonite Fossil: ',
    await nftInstance.methods.create(caller, tokenId + 3, 0, 'www.cradles.io/assets/ammonites/spiral').send({ from: caller }));

  console.log('create Beginner Potion: ',
    await nftInstance.methods.create(caller, tokenId + 4, 0, 'www.cradles.io/assets/potions/beginner').send({ from: caller }));

  console.log('create Intermediate Potion: ',
    await nftInstance.methods.create(caller, tokenId + 5, 0, 'www.cradles.io/assets/potions/intermediate').send({ from: caller }));

  console.log('create Advanced Potion: ',
    await nftInstance.methods.create(caller, tokenId + 6, 0, 'www.cradles.io/assets/potions/advanced').send({ from: caller }));

  console.log('create Golden Ammonite: ',
    await nftInstance.methods.create(caller, tokenId + 7, 0, 'www.cradles.io/assets/tickets/golden_ammonite').send({ from: caller }));

  console.log('grant minter role to market',
    await nftInstance.methods.grantRole(web3.utils.sha3('MINTER_ROLE'), marketAddress).send({ from: caller }));

  // start sale
  console.log('create token#1 sale pool',
    await marketInstance.methods.setSalePool(nftAddress, tokenId + 1, 20, '50000000000000000', '1', 1632466800).send({ from: caller }));

  console.log('create token#2 sale pool',
    await marketInstance.methods.setSalePool(nftAddress, tokenId + 2, 20, '80000000000000000', '1', 1632466800).send({ from: caller }));

  console.log('create token#3 sale pool',
    await marketInstance.methods.setSalePool(nftAddress, tokenId + 3, 20, '130000000000000000', '1', 1632466800).send({ from: caller }));

  console.log('create token#4 sale pool',
    await marketInstance.methods.setSalePool(nftAddress, tokenId + 4, 20, '50000000000000000', '1', 1632466800).send({ from: caller }));

  console.log('create token#5 sale pool',
    await marketInstance.methods.setSalePool(nftAddress, tokenId + 5, 20, '80000000000000000', '1', 1632466800).send({ from: caller }));

  console.log('create token#6 sale pool',
    await marketInstance.methods.setSalePool(nftAddress, tokenId + 6, 20, '130000000000000000', '1', 1632466800).send({ from: caller }));

  console.log('create token#7 sale pool',
    await marketInstance.methods.setSalePool(nftAddress, tokenId + 7, 20, '80000000000000000', '1', 1632466800).send({ from: caller }));

  console.log('query sale pool details',
    await marketInstance.methods.salePools(nftAddress, tokenId + 1).call());

  console.log('create  sale pool',
    await marketInstance.methods.buy(nftAddress, tokenId + 1, 1).send({ from: caller, value: '50000000000000000' }));
}

main();
