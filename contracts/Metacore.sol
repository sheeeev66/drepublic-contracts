// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "./ERC3664/extensions/ERC3664Combinable.sol";

contract Metacore is ERC3664Combinable, ERC721Enumerable, ReentrancyGuard, Ownable {
    using Strings for uint256;
    using SafeMath for uint256;

    uint256 private _curTokenId = 0;

    // cores
    uint256 public constant METACORE_ID = 1;
    uint256 public constant WEAPON_ID = 2;
    uint256 public constant CHEST_ID = 3;
    // components
    uint256 public constant SUFFIX_ID = 4;
    uint256 public constant NAMEPREFIX_ID = 5;
    uint256 public constant NAMESUFFIX_ID = 6;


    string[] private weapons = [
    "Warhammer",
    "Quarterstaff",
    "Maul",
    "Mace",
    "Club",
    "Katana",
    "Falchion",
    "Scimitar",
    "Long Sword",
    "Short Sword",
    "Ghost Wand",
    "Grave Wand",
    "Bone Wand",
    "Wand",
    "Grimoire",
    "Chronicle",
    "Tome",
    "Book"
    ];

    string[] private chestArmor = [
    "Divine Robe",
    "Silk Robe",
    "Linen Robe",
    "Robe",
    "Shirt",
    "Demon Husk",
    "Dragonskin Armor",
    "Studded Leather Armor",
    "Hard Leather Armor",
    "Leather Armor",
    "Holy Chestplate",
    "Ornate Chestplate",
    "Plate Mail",
    "Chain Mail",
    "Ring Mail"
    ];

    string[] private suffixes = [
    "of Power",
    "of Giants",
    "of Titans",
    "of Skill",
    "of Perfection",
    "of Brilliance",
    "of Enlightenment",
    "of Protection",
    "of Anger",
    "of Rage",
    "of Fury",
    "of Vitriol",
    "of the Fox",
    "of Detection",
    "of Reflection",
    "of the Twins"
    ];

    string[] private namePrefixes = [
    "Agony", "Apocalypse", "Armageddon", "Beast", "Behemoth", "Blight", "Blood", "Bramble",
    "Brimstone", "Brood", "Carrion", "Cataclysm", "Chimeric", "Corpse", "Corruption", "Damnation",
    "Death", "Demon", "Dire", "Dragon", "Dread", "Doom", "Dusk", "Eagle", "Empyrean", "Fate", "Foe",
    "Gale", "Ghoul", "Gloom", "Glyph", "Golem", "Grim", "Hate", "Havoc", "Honour", "Horror", "Hypnotic",
    "Kraken", "Loath", "Maelstrom", "Mind", "Miracle", "Morbid", "Oblivion", "Onslaught", "Pain",
    "Pandemonium", "Phoenix", "Plague", "Rage", "Rapture", "Rune", "Skull", "Sol", "Soul", "Sorrow",
    "Spirit", "Storm", "Tempest", "Torment", "Vengeance", "Victory", "Viper", "Vortex", "Woe", "Wrath",
    "Light's", "Shimmering"
    ];

    string[] private nameSuffixes = [
    "Bane",
    "Root",
    "Bite",
    "Song",
    "Roar",
    "Grasp",
    "Instrument",
    "Glow",
    "Bender",
    "Shadow",
    "Whisper",
    "Shout",
    "Growl",
    "Tear",
    "Peak",
    "Form",
    "Sun",
    "Moon"
    ];

    constructor() ERC3664Combinable() ERC721("Metacore Identity System", "MIS") Ownable() {
        _mint(METACORE_ID, "Metacore", "MetaName", "");
        _mint(WEAPON_ID, "Weapon", "Weapon", "");
        _mint(CHEST_ID, "Chest", "Chest", "");

        _mint(SUFFIX_ID, "Metacore Component Suffix", "Suffix", "");
        _mint(NAMEPREFIX_ID, "Metacore Component NamePrefix", "NamePrefix", "");
        _mint(NAMESUFFIX_ID, "Metacore Component NameSuffix", "NameSuffix", "");
    }

    function getNextTokenID() public view returns (uint256) {
        return _curTokenId.add(1);
    }

    function claimCore(string memory name) public nonReentrant {
        require(getNextTokenID() <= 8000, "Metacore: reached the maximum number of claim");

        _curTokenId += 1;
        _safeMint(_msgSender(), _curTokenId);
        attach(_curTokenId, METACORE_ID, 1, bytes(name));
        setMainAttribute(_curTokenId, METACORE_ID);
    }

    function claimWeapon(uint256 tokenId) public nonReentrant {
        require(tokenId > 8000 && tokenId <= 9000, "Weapon Token ID invalid");
        _safeMint(_msgSender(), tokenId);
        attach(tokenId, WEAPON_ID, 1, bytes(pluckInternal(tokenId, "WEAPON", weapons)));
        setMainAttribute(tokenId, WEAPON_ID);
    }

    function claimChest(uint256 tokenId) public nonReentrant {
        require(tokenId > 9000 && tokenId <= 10000, "Chest Token ID invalid");
        _safeMint(_msgSender(), tokenId);
        attach(tokenId, CHEST_ID, 1, bytes(pluckInternal(tokenId, "CHEST", chestArmor)));
        setMainAttribute(tokenId, CHEST_ID);
    }

    function combine(uint256 tokenId, uint256[] calldata subTokens) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Metacore: caller is not main token owner nor approved");
        require(getMainAttribute(tokenId) == METACORE_ID, "Metacore: invalid tokenId only Metacore can be synthesized");

        for (uint256 i = 0; i < subTokens.length; i++) {
            require(_isApprovedOrOwner(_msgSender(), subTokens[i]), "Metacore: caller is not sub token owner nor approved");
            _burn(subTokens[i]);
            super.combine(tokenId, subTokens[i]);
        }
    }

    function mintAttribute(
        uint256 attrId,
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) public onlyOwner {
        _mint(attrId, _name, _symbol, _uri);
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[3] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = getImageText(tokenId, 20);

        parts[2] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2]));
        string memory attributes = getAttributes(tokenId);

        if (getSubTokens(tokenId).length > 0) {
            attributes = string(abi.encodePacked(attributes, ',{"trait_type":"SYNTHETIC","value":"true"}'));
        } else {
            attributes = string(abi.encodePacked(attributes, ',{"trait_type":"SYNTHETIC","value":"false"}'));
        }

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', name(getMainAttribute(tokenId)), ' #', tokenId.toString(), '", "description": "MetaCore is an identity system which can make all metaverse citizens join into different metaverses by using same MetaCore Identity. The first modular NFT with MetaCore at its core, with arbitrary attributes addition and removal, freely combine and divide each components. Already adapted to multiple metaverse blockchain games. FUTURE IS COMMING", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '","attributes":[', attributes, ']}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }

    function getImageText(uint256 tokenId, uint256 pos) internal view returns (string memory) {
        uint256 attrId = getMainAttribute(tokenId);
        bytes memory text;
        if (attrId == METACORE_ID) {
            text = textOf(tokenId, attrId);
        } else if (attrId == WEAPON_ID) {
            text = bytes(getWeapon(tokenId));
        } else if (attrId == CHEST_ID) {
            text = bytes(getChest(tokenId));
        }
        return string(abi.encodePacked(text, getSubImageText(tokenId, pos)));
    }

    function getSubImageText(uint256 tokenId, uint256 pos) internal view returns (bytes memory) {
        bytes memory text = "";
        uint256[] memory tokens = getSubTokens(tokenId);
        for (uint i = 0; i < tokens.length; i++) {
            uint256 newPos = 20 * (i + 1) + pos;
            text = abi.encodePacked(text, '</text><text x="10" y="', newPos.toString(), '" class="base">');
            text = abi.encodePacked(text, getImageText(tokens[i], newPos));
        }
        return text;
    }

    function getAttributes(uint256 tokenId) internal view returns (string memory) {
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
        uint256[] memory subTokens = subTokens[tokenId];
        for (uint i = 0; i < subTokens.length; i++) {
            data = abi.encodePacked(data, ',');
            data = abi.encodePacked(data, getAttributes(subTokens[i]));
        }
        return data;
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getWeapon(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "WEAPON", weapons);
    }

    function getChest(uint256 tokenId) public view returns (string memory) {
        return pluck(tokenId, "CHEST", chestArmor);
    }

    function pluckInternal(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, tokenId.toString())));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 greatness = rand % 21;
        attach(tokenId, SUFFIX_ID, 1, bytes(suffixes[rand % suffixes.length]));

        if (greatness >= 10) {
            attach(tokenId, NAMEPREFIX_ID, 1, bytes(namePrefixes[rand % namePrefixes.length]));
            attach(tokenId, NAMESUFFIX_ID, 1, bytes(nameSuffixes[rand % nameSuffixes.length]));
        }
        return output;
    }

    function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, tokenId.toString())));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 greatness = rand % 21;

        output = string(abi.encodePacked(output, " ", suffixes[rand % suffixes.length]));

        if (greatness >= 10) {
            string[2] memory name;
            name[0] = namePrefixes[rand % namePrefixes.length];
            name[1] = nameSuffixes[rand % nameSuffixes.length];

            if (greatness == 19) {
                output = string(abi.encodePacked('"', name[0], ' ', name[1], '" ', output));
            } else {
                output = string(abi.encodePacked('"', name[0], ' ', name[1], '" ', output, " +1"));
            }
        }
        return output;
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