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
const nftAddress = "0x526Ea4DA866BC9D428A19e64cDF42F7Cb950689E";
const marketAddress = "0x41723D55FfcD59f766Def017DE5400cb2DE9Df03";

async function main() {
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

  let tokenId = 0;

  console.log('mint Nautilus Ammonite Fossil: ',
    await nftInstance.methods.create(caller, tokenId + 1, 0, "www.cradles.io/assets/ammonites/nautilus").send({ from: caller }));

  console.log('mint Shell Ammonite Fossil: ',
    await nftInstance.methods.create(caller, tokenId + 2, 0, "www.cradles.io/assets/ammonites/shell").send({ from: caller }));

  console.log('mint Spiral Shell Ammonite Fossil: ',
    await nftInstance.methods.create(caller, tokenId + 3, 0, "www.cradles.io/assets/ammonites/spiral").send({ from: caller }));

  console.log('mint Beginner Potion: ',
    await nftInstance.methods.create(caller, tokenId + 4, 0, "www.cradles.io/assets/potions/beginner").send({ from: caller }));

  console.log('mint Intermediate Potion: ',
    await nftInstance.methods.create(caller, tokenId + 5, 0, "www.cradles.io/assets/potions/intermediate").send({ from: caller }));

  console.log('mint Advanced Potion: ',
    await nftInstance.methods.create(caller, tokenId + 6, 0, "www.cradles.io/assets/potions/advanced").send({ from: caller }));

  console.log('mint Golden Ammonite: ',
    await nftInstance.methods.create(caller, tokenId + 7, 0, "www.cradles.io/assets/tickets/golden_ammonite").send({ from: caller }));

  console.log('grant minter role to market',
    await nftInstance.methods.grantRole(web3.utils.sha3('MINTER_ROLE'), marketAddress).send({ from: caller }));

  console.log('create sale pool',
    await marketInstance.methods.setSalePool(nftAddress, tokenId + 1, 3, "50000000000000000", "1", 0).send({ from: caller }));
}

main();
