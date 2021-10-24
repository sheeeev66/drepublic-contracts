const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const dragontarABI = require('../build/contracts/Dragontar.json');

const mnemonic = fs.readFileSync('.secret').toString().trim();
const bscLiveNetwork = 'https://bsc-dataseed1.binance.org/';
const bscTestNetwork = 'https://data-seed-prebsc-1-s1.binance.org:8545/';
const caller = '0xA5225cBEE5052100Ec2D2D94aA6d258558073757';

// bsctest
const dragontarAddress = '0x1f24b08091D5783D96e94472DfAc6C8243f06e1e';

async function main () {
  const provider = new HDWalletProvider(mnemonic, bscTestNetwork);
  const web3 = new Web3(provider);

  const dragontarInstance = new web3.eth.Contract(
    dragontarABI.abi,
    dragontarAddress,
    { gasLimit: '5500000' },
  );

  console.log('claim dragontar: ',
    await dragontarInstance.methods.claim().send({ from: caller }));

  const tokenId = await dragontarInstance.methods.getCurrentTokenID().call();
  console.log('dragontar tokenId: ', tokenId);

  console.log('dragontar fullId: ',
    await dragontarInstance.methods.fullIdOf(tokenId).call());

  console.log('dragontar rarity: ',
    await dragontarInstance.methods.rarityOf(tokenId).call());

  console.log('dragontar tokenURI: ',
    await dragontarInstance.methods.tokenURI(tokenId).call());
}

main();
