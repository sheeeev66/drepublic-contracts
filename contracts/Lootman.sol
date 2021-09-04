// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "./ERC3664/extensions/ERC3664Combinable.sol";

contract Lootman is ERC3664Combinable, ERC721Enumerable, ReentrancyGuard, Ownable {
    using Strings for uint256;

    string[] private rarely = ["SSR", "SR", "R"];

    // max length: 1000
    string[] public maleNames;
    // max length: 1000
    string[] public femaleNames;

    constructor(string memory name_, string memory symbol_) ERC3664Combinable() ERC721(name_, symbol_) Ownable() {
        require(maleNames.length == femaleNames.length, "Lootman: names length mismatch");
    }

    function claim(uint256 tokenId) public nonReentrant {
        require(tokenId > 0 && tokenId <= 1900, "Lootman: Token ID invalid");
        _safeMint(_msgSender(), tokenId);
        attach(tokenId, tokenId, 0);
    }

    function combine(uint256 tokenId, uint256[] calldata subs) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Lootman: caller is not main token owner nor approved");
        for (uint256 i = 0; i < subs.length; i++) {
            require(_isApprovedOrOwner(_msgSender(), subs[i]), "Lootman: caller is not sub token owner nor approved");
            _burn(subs[i]);
            super.combine(tokenId, subs[i]);
        }
    }

    function uploadMaleNames(string[] calldata _names, string _symbol) public nonReentrant onlyOwner {
        require(maleNames.length + _names.length <= 1000, "Lootman: Token ID invalid");
        for (uint i = 0; i < _names.length; i++) {
            maleNames.push(_names[i]);
        }
    }

    function uploadFemaleNames(string[] calldata _names) public nonReentrant onlyOwner {
        require(femaleNames.length + _names.length <= 1000, "Lootman: Token ID invalid");
        for (uint i = 0; i < _names.length; i++) {
            femaleNames.push(_names[i]);
        }
    }

    function ownerClaim(uint256 tokenId) public nonReentrant onlyOwner {
        require(tokenId > 1900 && tokenId <= 2000, "Lootman: Token ID invalid");
        _safeMint(owner(), tokenId);
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[3] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 300 100"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="25" class="base">';

        string memory name = "";
        string memory rare = "";
        (name, rare) = getName(tokenId);
        parts[1] = name;

        parts[2] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2]));
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "LFN #', tokenId.toString(), '", "description": "Lootman is a combinable identity system. Use lootman as your name in the metaverse and roam the metaverse. Stage 1: 2000 first names mint [start]. Stage 2: 2000 last names mint. Stage 3: combine complete names. Stage 4: post an attribute/body part every two days. Stage 5: free splicing complete your metaverse identity lootman!", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '",', '"attributes":[{"trait_type":"Rarely","value":"', rare, '"}]}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function getName(uint256 tokenId) internal view returns (string memory, string memory) {
        string memory name = "";
        string memory rare = "";
        uint256 i = 0;
        if (tokenId <= 1000) {
            i = tokenId - 1;
            name = maleNames[i];
        } else {
            i = (tokenId - 1) % 1000;
            name = femaleNames[i];
        }

        if (i < 100) {
            rare = rarely[0];
        } else if (i >= 100 && i < 400) {
            rare = rarely[1];
        } else {
            rare = rarely[2];
        }

        return (name, rare);
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}