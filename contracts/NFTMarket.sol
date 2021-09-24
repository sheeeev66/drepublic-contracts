// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "./ERC1155/ERC1155Tradable.sol";

contract NFTMarket is Ownable, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;

    struct SalePool {
        uint256 count;
        uint256 price;
        uint256 maxBuyCount;
        uint256 startTime;
        bool closed;
    }

    // nftAddress => tokenId => salePool
    mapping(address => mapping(uint256 => SalePool)) public salePools;

    address payable public treasury =
        payable(0x99F120C4BA7d3621e26429Cba45A6F52b23DFd1F);

    event SalePoolCreated(
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 count,
        uint256 price,
        uint256 maxBuyCount,
        uint256 startTime
    );
    event SalePoolStatus(
        address indexed nftAddress,
        uint256 indexed tokenId,
        bool isClosed
    );
    event Buy(
        address indexed nftAddress,
        address indexed buyer,
        uint256 indexed tokenId,
        uint256 count,
        uint256 value
    );

    constructor() {}

    function setSalePool(
        address nftAddress,
        uint256 tokenId,
        uint256 count,
        uint256 price,
        uint256 maxBuyCount,
        uint256 startTime
    ) external onlyOwner {
        require(maxBuyCount > 0, "NFTMarket: invalid max buy count");
        require(
            nftAddress.isContract(),
            "NFTMarket: NFT address must be contract address"
        );

        ERC1155Tradable nft = ERC1155Tradable(nftAddress);
        require(nft.exists(tokenId), "NFTMarket: tokenId not exists");
        require(
            startTime > block.timestamp,
            "NFTMarket: invalid sale start time"
        );

        SalePool storage pool = salePools[nftAddress][tokenId];
        pool.count = count;
        pool.price = price;
        pool.maxBuyCount = maxBuyCount;
        pool.startTime = startTime;

        emit SalePoolCreated(
            nftAddress,
            tokenId,
            count,
            price,
            maxBuyCount,
            startTime
        );
    }

    function setPoolStatus(
        address nftAddress,
        uint256 tokenId,
        bool isClosed
    ) external onlyOwner {
        SalePool storage pool = salePools[nftAddress][tokenId];
        pool.closed = isClosed;

        emit SalePoolStatus(nftAddress, tokenId, isClosed);
    }

    function buy(
        address nftAddress,
        uint256 tokenId,
        uint256 count
    ) external payable nonReentrant {
        SalePool storage pool = salePools[nftAddress][tokenId];
        require(
            count <= pool.maxBuyCount && count > 0,
            "NFTMarket: invalid buy count"
        );
        require(count <= pool.count, "NFTMarket: NFT not enough");
        require(pool.startTime <= block.timestamp, "NFTMarket: sale not start");
        require(!pool.closed, "NFTMarket: sale already ended");

        uint256 amount = pool.price * count;
        require(amount == msg.value, "NFTMarket: Payed invalid value");
        Address.sendValue(treasury, amount);

        ERC1155Tradable nft = ERC1155Tradable(nftAddress);
        require(nft.exists(tokenId), "NFTMarket: tokenId not exists");

        pool.count -= count;
        nft.mint(msg.sender, tokenId, count, "");

        emit Buy(nftAddress, msg.sender, tokenId, count, amount);
    }
}
