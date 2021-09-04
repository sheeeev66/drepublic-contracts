// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC3664.sol";

/**
 * @dev Implementation of the {ERC3664Combinable} interface.
 */
contract ERC3664Combinable is ERC3664 {

    mapping(uint256 => uint256[]) public bundles;

    // Mapping from token ID to approved another token.
    mapping(uint256 => uint256) private _combineApprovals;

    constructor () ERC3664(7) {}

//    function isApprovedCombine(uint256 from, uint256 to, uint256 attrId) public view virtual override returns (bool) {
//        return _allowances[attrId][from] == to;
//    }

    function combine(uint256 tokenId, uint256 sub) public virtual {
        bundles[tokenId].push(sub);
    }

//    function separate(uint256 tokenId, uint256[] sub) public virtual override {}
//
//    function approveCombine(uint256 from, uint256 to, uint256 attrId) public virtual override {}
//
//    function combineFrom(uint256 from, uint256 to, uint256 attrId) public virtual override {}
}
