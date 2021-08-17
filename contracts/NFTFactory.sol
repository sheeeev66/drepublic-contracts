// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155/ERC1155Preset.sol";
import "./EIP3664/IGenericAttribute.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/introspection/IERC1820Registry.sol";

/**
 * @title NFTFactory
 * NFTFactory - ERC1155 contract has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol(), and totalSupply()
 */
contract NFTFactory is ERC1155Preset {
    using SafeMath for uint256;

    uint256 private _currentNFTID = 0;

    mapping(uint256 => string) public fullIds;
    mapping(address => uint256[]) private holderTokens;
    mapping(uint256 => address) private tokenOwners;

    // attribute contracts
    address genericAttr;
    address upgradableAttr;
    address transferableAttr;
    address evolutiveAttr;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC1155Preset(_name, _symbol, _uri) {
    }

    function setGenericAttr(
        address _genericAttr
    ) public onlyOwner {
        genericAttr = _genericAttr;
    }

    function getNextTokenID() public view returns (uint256) {
        return _currentNFTID.add(1);
    }

    function createNFT(
        address _initialOwner,
        string memory _fullId,
        uint256[] calldata _attributes,
        uint256[] calldata _values
    ) public onlyOwner returns (uint256 tokenId) {
        require(_attributes.length == _values.length, "NFTFactory#batchCreate: id length mismatch");
        uint256 _id = _currentNFTID++;
        for (uint i = 0; i < _attributes.length; i++) {
            IGenericAttribute(genericAttr).attach(_id, _attributes[i], _values[i]);
        }
        fullIds[_id] = _fullId;
        tokenId = create(_initialOwner, _id, 1, "", "");
    }

    function batchCreateNFT(
        address[] calldata _initialOwners,
        string[] calldata _fullIds,
        uint256[][] calldata _attributes,
        uint256[][] calldata _values
    ) external onlyOwner returns (uint256[] memory tokenIds) {
        require(_initialOwners.length == _fullIds.length, "NFTFactory#batchCreate: id length mismatch");
        tokenIds = new uint256[](_initialOwners.length);
        for (uint i = 0; i < _initialOwners.length; i++) {
            createNFT(_initialOwners[i], _fullIds[i], _attributes[i], _values[i]);
        }
    }

}
