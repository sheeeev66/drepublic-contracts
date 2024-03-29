const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const Web3 = require('web3');
const dragontarABI = require('../build/contracts/Dragontar.json');
const dragontarDataABI = require('../build/contracts/DragontarData.json');
const dragontarAttrABI = require('../build/contracts/ERC721AutoId.json');

const mnemonic = fs.readFileSync('.secret').toString().trim();
const bscLiveNetwork = 'https://bsc-dataseed1.binance.org/';
const bscTestNetwork = 'https://data-seed-prebsc-1-s1.binance.org:8545/';

const INFURA_API_KEY = process.env.INFURA_API_KEY;
const mubaiNetwork = `https://polygon-mumbai.infura.io/v3/${INFURA_API_KEY}`;
const caller = '0xA5225cBEE5052100Ec2D2D94aA6d258558073757';

// bsctest
const dragontarAddress = '0x448B562AC0A5cb7E6D6E360E5f9EEf9B57a9c608';
const dragontarDataAddress = '0x4B2Bb4b24221EaCe19F79E2aD5242218864d3f00';
const dragontarAttrAddress = '0xBFe36Fc35f1cB3781850F8C16B67e49A1F568826';

const provider = new HDWalletProvider(mnemonic, mubaiNetwork);
const web3 = new Web3(provider);

const dragontarInstance = new web3.eth.Contract(
  dragontarABI.abi,
  dragontarAddress,
  { gasLimit: '5500000' },
);

const dragontarDataInstance = new web3.eth.Contract(
  dragontarDataABI.abi,
  dragontarDataAddress,
  { gasLimit: '5500000' },
);

const dragontarAttrInstance = new web3.eth.Contract(
  dragontarAttrABI.abi,
  dragontarAttrAddress,
  { gasLimit: '5500000' },
);
const MINTER_ROLE = Web3.utils.soliditySha3('MINTER_ROLE');

async function main () {
  // for (let i = 0; i < 1000; i++) {
  //   await dragontar(i);
  // }

  console.log('claim dragontar: ',
    await dragontarInstance.methods.claim().send({ from: caller }));

  const tokenId = await dragontarInstance.methods.getCurrentTokenID().call();
  console.log('dragontar tokenId: ', tokenId);
  const attrId = 3;

  console.log('dragontar fullId: ',
    await dragontarInstance.methods.fullIdOf(tokenId).call());

  console.log('dragontar rarity: ',
    await dragontarInstance.methods.rarityOf(tokenId).call());

  console.log('dragontar tokenURI: ',
    await dragontarInstance.methods.tokenURI(tokenId).call());

  console.log('grant dragontar mint attrNFT role: ',
    await dragontarAttrInstance.methods.grantRole(MINTER_ROLE, dragontarAddress).send({ from: caller }));

  console.log('separate dragontar: ',
    await dragontarInstance.methods.separateOne(tokenId, attrId).send({ from: caller }));

  const attrTokenId = await dragontarInstance.methods.getAttrTokenId(dragontarAddress, tokenId, attrId).call();
  console.log('dragontar attrTokenId: ', attrTokenId);

  console.log('dragontar attrTokenId owner: ', await dragontarAttrInstance.methods.ownerOf(attrTokenId).call());

  console.log('approve nft to dragontar: ',
    await dragontarAttrInstance.methods.setApprovalForAll(dragontarAddress, true).send({ from: caller }));

  console.log('combine dragontar: ',
    await dragontarInstance.methods.combine(tokenId, attrTokenId, attrId).send({ from: caller }));
}

async function dragontar (tokenId) {
  console.log('dragontar getBackground: ',
    await dragontarDataInstance.methods.getBackground(tokenId).call());

  console.log('dragontar getBody: ',
    await dragontarDataInstance.methods.getBody(tokenId).call());

  console.log('dragontar getDress: ',
    await dragontarDataInstance.methods.getDress(tokenId).call());

  console.log('dragontar getNeck: ',
    await dragontarDataInstance.methods.getNeck(tokenId).call());

  console.log('dragontar getEye: ',
    await dragontarDataInstance.methods.getEye(tokenId).call());

  console.log('dragontar getEar: ',
    await dragontarDataInstance.methods.getEar(tokenId).call());

  console.log('dragontar getMouth: ',
    await dragontarDataInstance.methods.getMouth(tokenId).call());

  console.log('dragontar getDecorate: ',
    await dragontarDataInstance.methods.getDecorate(tokenId).call());

  console.log('dragontar getHat: ',
    await dragontarDataInstance.methods.getHat(tokenId).call());

  console.log('dragontar getTooth: ',
    await dragontarDataInstance.methods.getTooth(tokenId).call());
}

main();
