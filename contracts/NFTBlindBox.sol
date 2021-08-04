// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";
import "openzeppelin-solidity/contracts/utils/math/Math.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/introspection/IERC1820Registry.sol";
import "openzeppelin-solidity/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC777/IERC777.sol";
import "openzeppelin-solidity/contracts/token/ERC777/IERC777Recipient.sol";
import "openzeppelin-solidity/contracts/token/ERC1155/IERC1155.sol";
import "openzeppelin-solidity/contracts/token/ERC1155/IERC1155Receiver.sol";

contract NFTBlindBox is IERC777Recipient, Ownable, IERC1155Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    bytes4 internal constant ERC1155_RECEIVED_VALUE = 0xf23a6e61;
    bytes4 internal constant ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;
    
    IERC1820Registry private _erc1820 = IERC1820Registry(
        0x88887eD889e776bCBe2f0f9932EcFaBcDfCd1820
    );
    // keccak256("ERC777TokensRecipient")
    bytes32
    private constant TOKENS_RECIPIENT_INTERFACE_HASH = 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;
    
    address public nft;
    // chain native token
    address public cnt;
    // drepublic coin
    address public drpc;
    // usdt
    address public usdt;
    
    struct StageInfo {
        uint256 cntPrice;
        uint256 drpcPrice;
        uint256 usdtPrice;
    }
    
    struct InviteInfo {
        uint256 count;
    }
    
    // stageNum => NFTs
    mapping(uint256 => uint256[]) private nftIds;
    // stageNum => stageInfo
    mapping(uint256 => StageInfo) public stages;
    mapping(address => address) public inviter;
    mapping(address => InviteInfo) public userInvited;
    mapping(uint256 => bool) public nftOnSale;
    
    event BlindBoxBuy(
        address indexed to,
        uint256 tokenId,
        uint256 value,
        uint256 stageNum
    );
    
    constructor(
        address _nft,
        address _cnt,
        address _drpc,
        address _usdt
    ) {
        nft = _nft;
        cnt = _cnt;
        drpc = _drpc;
        usdt = _usdt;
        
        _erc1820.setInterfaceImplementer(
            address(this),
            TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
    }
    
    function getNFTLength(uint256 stageNum) public view returns (uint256) {
        return nftIds[stageNum].length;
    }
    
    function getNFTList(uint256 stageNum, uint256 begin)
    public
    view
    returns (uint256[] memory)
    {
        require(
            begin >= 0 && begin < nftIds[stageNum].length,
            "NFTMarket: NFTsList out of range"
        );
        uint256 range = Math.min(nftIds[stageNum].length, begin.add(100));
        uint256[] memory res = new uint256[](range);
        for (uint256 i = begin; i < range; i++) {
            res[i - begin] = nftIds[stageNum][i];
        }
        return res;
    }
    
    function setPrices(
        uint256 stageNum,
        uint256 _cntPrice,
        uint256 _drpcPrice,
        uint256 _usdtPrice
    ) external onlyOwner {
        StageInfo memory _stageInfo = stages[stageNum];
        _stageInfo.cntPrice = _cntPrice;
        _stageInfo.drpcPrice = _drpcPrice;
        _stageInfo.usdtPrice = _usdtPrice;
        stages[stageNum] = _stageInfo;
    }
    
    function setNFT(address _nft) external onlyOwner {
        nft = _nft;
    }
    
    function _seed(address _user, uint256 _supply)
    internal
    view
    returns (uint256)
    {
        return
        uint256(
            uint256(
                keccak256(
                    abi.encodePacked(
                        _user,
                        block.number,
                        block.timestamp,
                        block.difficulty
                    )
                )
            ) % _supply
        );
    }
    
    function _buy(uint256 stageNum, address _from)
    internal
    returns (uint256 _tokenId)
    {
        uint256 length = nftIds[stageNum].length;
        require(length > 0, "NFTMarket: Already sold out");
        uint256 _index = _seed(_from, length);
        _tokenId = nftIds[stageNum][_index];
        nftIds[stageNum][_index] = nftIds[stageNum][length - 1];
        nftIds[stageNum].pop();
        nftOnSale[_tokenId] = false;
        IERC1155(nft).safeTransferFrom(
            address(this),
            _from,
            _tokenId,
            1,
            ""
        );
        emit BlindBoxBuy(_from, _tokenId, 1, stageNum);
    }
    
    function _invite(address from, address _inviter)
    internal
    returns (address)
    {
        address reward_to = inviter[from];
        if (reward_to == address(0) && _inviter != address(0)) {
            reward_to = _inviter;
            inviter[from] = reward_to;
            userInvited[reward_to].count++;
        }
        require(reward_to != from, "invite can not be self");
        return reward_to;
    }
    
    // erc777 receiveToken
    function tokensReceived(
        address operator,
        address from,
        address /* to */,
        uint256 amount,
        bytes calldata userData,
        bytes calldata /*_operatorData*/
    ) override external {
        if (userData.length != 64) {
            return;
        }
        require(operator == from, "NFTSale: only wallet");
        uint256 stageNum;
        address _inviter;
        (stageNum, _inviter) = abi.decode(userData, (uint256, address));
        _inviter = _invite(from, _inviter);
        uint256 count;
        if (msg.sender == drpc) {
            uint256 drpcPrice = stages[stageNum].drpcPrice;
            require(
                drpcPrice > 0 && amount >= drpcPrice,
                "NFTMarket:payment amount less than drpc price"
            );
            count = amount.div(drpcPrice);
        } else if (msg.sender == cnt) {
            uint256 cntPrice = stages[stageNum].cntPrice;
            require(
                cntPrice > 0 && amount >= cntPrice,
                "NFTMarket:payment amount less than cnt price"
            );
            count = amount.div(cntPrice);
        } else {
            revert("pay token is not correct");
        }
        for (uint256 i = 0; i < count; i++) {
            _buy(stageNum, from);
        }
    }
    
    function onERC1155Received(
        address /*_operator*/,
        address /*_from*/,
        uint256 /*_id*/,
        uint256 /*_amount*/,
        bytes calldata /*_data*/
    ) override external pure returns (bytes4) {
        return ERC1155_RECEIVED_VALUE;
    }
    
    function onERC1155BatchReceived(
        address /*_operator*/,
        address /*_from*/,
        uint256[] calldata /*_ids*/,
        uint256[] calldata /*_amounts*/,
        bytes calldata /*_data*/
    ) override external pure returns (bytes4) {
        return ERC1155_BATCH_RECEIVED_VALUE;
    }
    
    function supportsInterface(bytes4 /*interfaceID*/)
    override
    external
    pure
    returns (bool)
    {
        return true;
    }
}
