// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Loot.sol";
import "./Synthetic/ISynthetic.sol";

contract SLoot is ISynthetic, Loot {
    using Strings for uint256;

    constructor() Loot() {}

    function tokenTexts(uint256 tokenId) public view virtual override returns (string[] memory) {
        string[] memory parts = new string[](8);
        parts[0] = getWeapon(tokenId);
        parts[1] = getChest(tokenId);
        parts[2] = getHead(tokenId);
        parts[3] = getWaist(tokenId);
        parts[4] = getFoot(tokenId);
        parts[5] = getHand(tokenId);
        parts[6] = getNeck(tokenId);
        parts[7] = getRing(tokenId);
        return parts;
    }

    function tokenAttributes(uint256 tokenId) public view virtual override returns (string memory) {
        bytes memory data = "";
        data = abi.encodePacked(data, pluckAttribute(tokenId, "WEAPON", weapons), ',');
        data = abi.encodePacked(data, pluckAttribute(tokenId, "CHEST", chestArmor), ',');
        data = abi.encodePacked(data, pluckAttribute(tokenId, "HEAD", headArmor), ',');
        data = abi.encodePacked(data, pluckAttribute(tokenId, "WAIST", waistArmor), ',');
        data = abi.encodePacked(data, pluckAttribute(tokenId, "FOOT", footArmor), ',');
        data = abi.encodePacked(data, pluckAttribute(tokenId, "HAND", handArmor), ',');
        data = abi.encodePacked(data, pluckAttribute(tokenId, "NECK", necklaces), ',');
        data = abi.encodePacked(data, pluckAttribute(tokenId, "RING", rings));
        return string(data);
    }

    function pluckAttribute(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, tokenId.toString())));
        string memory output = sourceArray[rand % sourceArray.length];

        bytes memory data = concatAttribute(keyPrefix, '', output);

        uint256 greatness = rand % 21;
        if (greatness > 14) {
            data = abi.encodePacked(data, ',', concatAttribute(keyPrefix, "suffix", suffixes[rand % suffixes.length]));
        }
        if (greatness >= 19) {
            data = abi.encodePacked(data, ',', concatAttribute(keyPrefix, "namePrefixes", namePrefixes[rand % namePrefixes.length]));
            data = abi.encodePacked(data, ',', concatAttribute(keyPrefix, "nameSuffixes", nameSuffixes[rand % nameSuffixes.length]));
            if (greatness > 19) {
                data = abi.encodePacked(data, ',', concatAttribute(keyPrefix, "greatness", "+1"));
            }
        }
        return string(data);
    }

    function concatAttribute(string memory keyPrefix, string memory key, string memory value) internal pure returns (bytes memory)  {
        return abi.encodePacked('{"trait_type":"', keyPrefix, ' ', key, '","value":"', value, '"}');
    }
}
