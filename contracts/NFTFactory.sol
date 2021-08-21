// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./utils/Arrays.sol";
import "./ERC1155/ERC1155Preset.sol";
import "./ERC3664/IGenericAttribute.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";

/**
 * @title NFTFactory
 * NFTFactory - ERC1155 contract has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol(), and totalSupply()
 */
contract NFTFactory is ERC1155Preset {
    using Arrays for uint256[];
    using SafeMath for uint256;

    uint256 private _currentNFTId = 0;

    mapping(uint256 => string) public tokenMetadatas;
    mapping(uint256 => address) public tokenOwners;
    mapping(address => uint256[]) public holderTokens;
    mapping(uint16 => address) public attributes;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC1155Preset(_name, _symbol, _uri) {
    }

    function registerAttribute(uint16 _class, address _attr) public onlyOwner {
        attributes[_class] = _attr;
    }

    function getNextTokenID() public view returns (uint256) {
        return _currentNFTId.add(1);
    }

    function createNFT(
        address _initialOwner,
        string memory _metadata
    ) public onlyOwner returns (uint256 tokenId) {
        uint256 _id = _currentNFTId++;
        tokenMetadatas[_id] = _metadata;

        // create nft only support generic attribute class.
        uint16 genericClass = 1;
        _decodeMetadata(_id, _metadata, genericClass);

        tokenId = create(_initialOwner, _id, 1, "", "");
    }

    function batchCreateNFT(
        address[] calldata _initialOwners,
        string[] calldata _metadatas
    ) external onlyOwner returns (uint256[] memory tokenIds) {
        require(_initialOwners.length == _metadatas.length, "NFTFactory#batchCreate: id length mismatch");
        tokenIds = new uint256[](_initialOwners.length);
        for (uint i = 0; i < _initialOwners.length; i++) {
            createNFT(_initialOwners[i], _metadatas[i]);
        }
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155Pausable) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            tokenOwners[ids[i]] = to;
            if (from != address(0)) {
                holderTokens[from].removeByValue(ids[i]);
            }
            if (to != address(0)) {
                holderTokens[to].push(ids[i]);
            }
        }
    }

    function _decodeMetadata(uint256 _id, string memory _metadata, uint16 _class) internal {
        require(_validAttrClass(_class), "NFTFactory#_decodeMetadata: invalid attribute class");
        // TODO
        uint256[] memory _attributes;
        uint256[] memory _values;
        for (uint i = 0; i < _attributes.length; i++) {
            IGenericAttribute(attributes[_class]).attach(_id, _attributes[i], _values[i]);
        }
    }

    function _validAttrClass(
        uint16 _id
    ) internal view returns (bool) {
        return attributes[_id] != address(0);
    }

}
