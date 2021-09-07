// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC3664.sol";

/**
 * @dev Implementation of the {ERC3664Combinable} interface.
 */
contract ERC3664Combinable is ERC3664 {
    struct SynthesizedToken {
        address token;
        address owner;
        uint256 id;
    }

    // mainToken => SynthesizedToken
    mapping(uint256 => SynthesizedToken[]) public synthesizedTokens;

    // subToken => mainToken => address
    mapping(uint256 => mapping(uint256 => address)) public subTokens;

    mapping(uint256 => uint256) public rawAttribute;

    // Mapping from token ID to approved another token.
    mapping(uint256 => uint256) private _combineApprovals;

    constructor () ERC3664(7) {}

    //    function isApprovedCombine(uint256 from, uint256 to, uint256 attrId) public view virtual override returns (bool) {
    //        return _allowances[attrId][from] == to;
    //    }

    function recordSynthesized(
        uint256 tokenId,
        address subToken,
        uint256 subId
    ) public {
        synthesizedTokens[tokenId].push(SynthesizedToken(subToken, _msgSender(), subId));
        subTokens[subId][tokenId] = subToken;
    }

    function setRawAttribute(uint256 tokenId, uint256 attrId) public virtual {
        rawAttribute[tokenId] = attrId;
    }

    function getRawAttribute(uint256 tokenId) public view returns (uint256) {
        return rawAttribute[tokenId];
    }

    function getSynthesizedTokens(uint256 tokenId) public view returns (SynthesizedToken[] memory) {
        return synthesizedTokens[tokenId];
    }

    function tokenAttributes(uint256 tokenId) internal view returns (string memory) {
        bytes memory data = "";
        uint256[] memory attrs = attributesOf(tokenId);
        for (uint i = 0; i < attrs.length; i++) {
            if (data.length > 0) {
                data = abi.encodePacked(data, ',');
            }
            data = abi.encodePacked(data, '{"trait_type":"', symbol(attrs[i]), '","value":"', textOf(tokenId, attrs[i]), '"}');
        }
        data = abi.encodePacked(data, getSubAttributes(tokenId));

        return string(data);
    }

    function getSubAttributes(uint256 tokenId) internal view returns (bytes memory) {
        bytes memory data = "";
        SynthesizedToken[] memory sTokens = synthesizedTokens[tokenId];
        for (uint i = 0; i < sTokens.length; i++) {
            if (data.length > 0) {
                data = abi.encodePacked(data, ',');
            }
            data = abi.encodePacked(data, tokenAttributes(sTokens[i].id));
        }
        return data;
    }

    //
    //    function approveCombine(uint256 from, uint256 to, uint256 attrId) public virtual override {}
    //
    //    function combineFrom(uint256 from, uint256 to, uint256 attrId) public virtual override {}
}
