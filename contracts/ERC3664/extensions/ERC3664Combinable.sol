// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC3664.sol";

/**
 * @dev Implementation of the {ERC3664Combinable} interface.
 */
contract ERC3664Combinable is ERC3664 {

    mapping(uint256 => uint256[]) public subTokens;

    mapping(uint256 => uint256) public mainAttribute;

    // Mapping from token ID to approved another token.
    mapping(uint256 => uint256) private _combineApprovals;

    constructor () ERC3664(7) {}

    //    function isApprovedCombine(uint256 from, uint256 to, uint256 attrId) public view virtual override returns (bool) {
    //        return _allowances[attrId][from] == to;
    //    }

    function combine(uint256 tokenId, uint256 sub) public virtual {
        subTokens[tokenId].push(sub);
    }

    function setMainAttribute(uint256 tokenId, uint256 attrId) public virtual {
        mainAttribute[tokenId] = attrId;
    }

    function getMainAttribute(uint256 tokenId) public view returns (uint256) {
        return mainAttribute[tokenId];
    }

    function getSubTokens(uint256 tokenId) public view returns (uint256[] memory) {
        return subTokens[tokenId];
    }

    //    function separate(uint256 tokenId, uint256[] sub) public virtual override {}
    //
    //    function approveCombine(uint256 from, uint256 to, uint256 attrId) public virtual override {}
    //
    //    function combineFrom(uint256 from, uint256 to, uint256 attrId) public virtual override {}
}
