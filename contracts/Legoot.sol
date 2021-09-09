// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SLoot.sol";
//import "./Synthetic/ISynthetic.sol";
import "./ERC3664/ERC3664.sol";

contract Legoot is ERC3664, SLoot {
    using Strings for uint256;

    uint256 public constant SLOOT_NFT = 1;
    uint256 public constant WEAPON_NFT = 2;
    uint256 public constant CHEST_NFT = 3;
    uint256 public constant HEAD_NFT = 4;
    uint256 public constant WAIST_NFT = 5;
    uint256 public constant FOOT_NFT = 6;
    uint256 public constant HAND_NFT = 7;
    uint256 public constant NECK_NFT = 8;
    uint256 public constant RING_NFT = 9;

    struct SynthesizedToken {
        address owner;
        uint256 id;
    }

    // mainToken => SynthesizedToken
    mapping(uint256 => SynthesizedToken[]) public synthesizedTokens;

    constructor() SLoot() {
        _mint(SLOOT_NFT, "", "lootcore", "");
        _mint(WEAPON_NFT, "", "weapon", "");
        _mint(CHEST_NFT, "", "chest", "");
        _mint(HEAD_NFT, "", "head", "");
        _mint(WAIST_NFT, "", "waist", "");
        _mint(FOOT_NFT, "", "foot", "");
        _mint(HAND_NFT, "", "hand", "");
        _mint(NECK_NFT, "", "neck", "");
        _mint(RING_NFT, "", "ring", "");
    }

    function _afterTokenClaim(uint256 tokenId) internal virtual override {
        attach(tokenId, SLOOT_NFT, 1, bytes(""), true);
        // WEAPON
        _mintSubToken(WEAPON_NFT, tokenId, tokenId + _totalSupply + 1);
        // CHEST
        _mintSubToken(CHEST_NFT, tokenId, tokenId + _totalSupply + 2);
        // HEAD
        _mintSubToken(HEAD_NFT, tokenId, tokenId + _totalSupply + 3);
        // WAIST
        _mintSubToken(WAIST_NFT, tokenId, tokenId + _totalSupply + 4);
        // FOOT
        _mintSubToken(FOOT_NFT, tokenId, tokenId + _totalSupply + 5);
        // HAND
        _mintSubToken(HAND_NFT, tokenId, tokenId + _totalSupply + 6);
        // NECK
        _mintSubToken(NECK_NFT, tokenId, tokenId + _totalSupply + 7);
        // RING
        _mintSubToken(RING_NFT, tokenId, tokenId + _totalSupply + 8);
    }

    function _mintSubToken(uint256 attr, uint256 tokenId, uint256 subId) internal virtual {
        _safeMint(address(this), subId);
        attach(subId, attr, 1, bytes(""), true);
        _recordSynthesized(_msgSender(), tokenId, subId);
    }

    function _recordSynthesized(address owner, uint256 tokenId, uint256 subId) internal {
        synthesizedTokens[tokenId].push(SynthesizedToken(owner, subId));
    }

    function combine(
        uint256 tokenId,
        uint256[] calldata subIds
    ) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "SLoot: caller is not token owner nor approved");

        for (uint256 i = 0; i < subIds.length; i++) {
            require(getApproved(subIds[i]) == address(this), "SLoot: caller is not sub token owner nor approved");

            transferFrom(_msgSender(), address(this), subIds[i]);
            _recordSynthesized(_msgSender(), tokenId, subIds[i]);
        }
    }

    function separate(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "SLoot: caller is not token owner nor approved");

        SynthesizedToken[] memory subs = synthesizedTokens[tokenId];
        require(subs.length > 0, "SLoot: not synthesized token");
        for (uint256 i = 0; i < subs.length; i++) {
            transferFrom(address(this), subs[i].owner, subs[i].id);
        }
        delete synthesizedTokens[tokenId];
    }

    function separateOne(uint256 tokenId, uint256 subId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "SLoot: caller is not token owner nor approved");
        uint idx = _findByValue(synthesizedTokens[tokenId], subId);
        SynthesizedToken memory token = synthesizedTokens[tokenId][idx];
        transferFrom(address(this), token.owner, token.id);
        delete synthesizedTokens[tokenId][idx];
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[4] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = string(abi.encodePacked(symbol(primaryAttributeOf(tokenId)), ' #', tokenId.toString(), '</text><text x="10" y="40" class="base">'));

        parts[2] = getImageText(tokenId, 40);

        parts[3] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3]));
        string memory attributes = getAttributes(tokenId);

        if (synthesizedTokens[tokenId].length > 0) {
            attributes = string(abi.encodePacked(attributes, ',{"trait_type":"SYNTHETIC","value":"true"}'));
        } else {
            attributes = string(abi.encodePacked(attributes, ',{"trait_type":"SYNTHETIC","value":"false"}'));
        }

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', symbol(primaryAttributeOf(tokenId)), ' #', tokenId.toString(), '", "description": "MetaCore is an identity system which can make all metaverse citizens join into different metaverses by using same MetaCore Identity. The first modular NFT with MetaCore at its core, with arbitrary attributes addition and removal, freely combine and divide each components. Already adapted to multiple metaverse blockchain games. FUTURE IS COMMING", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '","attributes":[', attributes, ']}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }

    function getImageText(uint256 tokenId, uint256 pos) public view returns (string memory) {
        bytes memory text;
        SynthesizedToken[] memory tokens = synthesizedTokens[tokenId];
        for (uint i = 0; i < tokens.length; i++) {
            uint256 newPos = 20 * (i + 1) + pos;
            text = abi.encodePacked(text, '</text><text x="10" y="', newPos.toString(), '" class="base">');
            text = abi.encodePacked(text, tokenText(tokens[i].id));
        }
        return string(text);
    }

    function tokenText(uint256 tokenId) public view virtual returns (string memory) {
        uint256 nft_type = primaryAttributeOf(tokenId);
        if (nft_type == WEAPON_NFT) {
            return getWeapon(tokenId);
        } else if (nft_type == CHEST_NFT) {
            return getChest(tokenId);
        } else if (nft_type == HEAD_NFT) {
            return getHead(tokenId);
        } else if (nft_type == WAIST_NFT) {
            return getWaist(tokenId);
        } else if (nft_type == FOOT_NFT) {
            return getFoot(tokenId);
        } else if (nft_type == HAND_NFT) {
            return getHand(tokenId);
        } else if (nft_type == NECK_NFT) {
            return getNeck(tokenId);
        } else if (nft_type == RING_NFT) {
            return getRing(tokenId);
        } else {
            return "";
        }
    }

    function getAttributes(uint256 tokenId) public view returns (string memory) {
        bytes memory data = bytes(tokenAttributes(tokenId));
        SynthesizedToken[] memory tokens = synthesizedTokens[tokenId];
        for (uint i = 0; i < tokens.length; i++) {
            if (data.length > 0) {
                data = abi.encodePacked(data, ',', tokenAttributes(tokens[i].id));
            } else {
                data = bytes(tokenAttributes(tokens[i].id));
            }
        }
        return string(data);
    }

    function tokenAttributes(uint256 tokenId) public view virtual returns (string memory) {
        uint256 nft_type = primaryAttributeOf(tokenId);
        if (nft_type == WEAPON_NFT) {
            return _pluckAttribute(tokenId, "WEAPON", weapons);
        } else if (nft_type == CHEST_NFT) {
            return _pluckAttribute(tokenId, "CHEST", chestArmor);
        } else if (nft_type == HEAD_NFT) {
            return _pluckAttribute(tokenId, "HEAD", headArmor);
        } else if (nft_type == WAIST_NFT) {
            return _pluckAttribute(tokenId, "WAIST", waistArmor);
        } else if (nft_type == FOOT_NFT) {
            return _pluckAttribute(tokenId, "FOOT", footArmor);
        } else if (nft_type == HAND_NFT) {
            return _pluckAttribute(tokenId, "HAND", handArmor);
        } else if (nft_type == NECK_NFT) {
            return _pluckAttribute(tokenId, "NECK", necklaces);
        } else if (nft_type == RING_NFT) {
            return _pluckAttribute(tokenId, "RING", rings);
        } else {
            return "";
        }
    }

    function _pluckAttribute(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, tokenId.toString())));
        string memory output = sourceArray[rand % sourceArray.length];

        bytes memory data = _concatAttribute(keyPrefix, '', output);

        uint256 greatness = rand % 21;
        if (greatness > 14) {
            data = abi.encodePacked(data, ',', _concatAttribute(keyPrefix, "suffix", suffixes[rand % suffixes.length]));
        }
        if (greatness >= 19) {
            data = abi.encodePacked(data, ',', _concatAttribute(keyPrefix, "namePrefixes", namePrefixes[rand % namePrefixes.length]));
            data = abi.encodePacked(data, ',', _concatAttribute(keyPrefix, "nameSuffixes", nameSuffixes[rand % nameSuffixes.length]));
            if (greatness > 19) {
                data = abi.encodePacked(data, ',', _concatAttribute(keyPrefix, "greatness", "+1"));
            }
        }
        return string(data);
    }

    function _concatAttribute(string memory keyPrefix, string memory key, string memory value) internal pure returns (bytes memory)  {
        return abi.encodePacked('{"trait_type":"', keyPrefix, ' ', key, '","value":"', value, '"}');
    }

    function _findByValue(SynthesizedToken[] storage values, uint256 value) internal view returns (uint) {
        uint i = 0;
        while (values[i].id != value) {
            i++;
        }
        return i;
    }
}
