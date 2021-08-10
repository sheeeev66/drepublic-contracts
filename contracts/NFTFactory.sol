// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155/ERC1155Preset.sol";
import "openzeppelin-solidity/contracts/utils/introspection/IERC1820Registry.sol";

/**
 * @title NFTFactory
 * NFTFactory - ERC1155 contract has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol(), and totalSupply()
 */
contract NFTFactory is ERC1155Preset {
    
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC1155Preset(_name, _symbol, _uri) {
    }
    
    function createNFT(
        address _initialOwner,
        uint256 _id
    ) public onlyOwner returns (uint256 tokenId) {
        tokenId = create(_initialOwner, _id, 1, "", "");
    }
    
    function batchCreateNFT(
        address[] calldata _initialOwners,
        uint256[] calldata _ids
    ) external onlyOwner returns (uint256[] memory tokenIds) {
        require(_initialOwners.length == _ids.length, "NFTFactory#batchCreate: id length mismatch");
        tokenIds = new uint256[](_initialOwners.length);
        for (uint i = 0; i < _initialOwners.length; i++) {
            tokenIds[i] = create(_initialOwners[i], _ids[i], 1, "", "");
        }
    }
    
}
