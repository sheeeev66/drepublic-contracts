// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "./Synthetic/ISynthetic.sol";
import "./ERC3664/ERC3664.sol";

interface ILoot {
    function getWeapon(uint256 tokenId) external view returns (string memory);

    function getChest(uint256 tokenId) external view returns (string memory);

    function getHead(uint256 tokenId) external view returns (string memory);

    function getWaist(uint256 tokenId) external view returns (string memory);

    function getFoot(uint256 tokenId) external view returns (string memory);

    function getHand(uint256 tokenId) external view returns (string memory);

    function getNeck(uint256 tokenId) external view returns (string memory);

    function getRing(uint256 tokenId) external view returns (string memory);
}

interface ILootData {
    function getWeapons() external view returns (string[] memory);

    function getChest() external view returns (string[]  memory);

    function getHead() external view returns (string[]  memory);

    function getWaist() external view returns (string[]  memory);

    function getFoot() external view returns (string[]  memory);

    function getHand() external view returns (string[]  memory);

    function getNecklaces() external view returns (string[]  memory);

    function getRings() external view returns (string[]  memory);

    function getSuffixes() external view returns (string[]  memory);

    function getNamePrefixes() external view returns (string[]  memory);

    function getNameSuffixes() external view returns (string[] memory);
}

contract Legoot is ERC3664, ISynthetic, ERC721Enumerable, ReentrancyGuard, Ownable {
    using Strings for uint256;

    // mainnet
    //address public constant LOOT = 0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7;
    // rinkeby
    address public constant LOOT = 0x5C44B86e21f49cA7e66BB2381D3acD1004E4a1A2;
    address public constant LOOTDATA = 0x283D93B97b0923c833374c6401eF74B837B64cAf;

    uint256 public constant LEGOOT_NFT = 1;
    uint256 public constant WEAPON_NFT = 2;
    uint256 public constant CHEST_NFT = 3;
    uint256 public constant HEAD_NFT = 4;
    uint256 public constant WAIST_NFT = 5;
    uint256 public constant FOOT_NFT = 6;
    uint256 public constant HAND_NFT = 7;
    uint256 public constant NECK_NFT = 8;
    uint256 public constant RING_NFT = 9;

    string private _name = "Legoot";

    uint256 public _totalSupply = 8000;

    struct SynthesizedToken {
        address owner;
        uint256 id;
    }

    // mainToken => SynthesizedToken
    mapping(uint256 => SynthesizedToken[]) public synthesizedTokens;

    constructor() ERC721("Legoot", "LEGO") Ownable() {
        _mint(LEGOOT_NFT, "LEGOOT", "legoot", "");
        _mint(WEAPON_NFT, "WEAPON", "weapon", "");
        _mint(CHEST_NFT, "CHEST", "chest", "");
        _mint(HEAD_NFT, "HEAD", "head", "");
        _mint(WAIST_NFT, "WAIST", "waist", "");
        _mint(FOOT_NFT, "FOOT", "foot", "");
        _mint(HAND_NFT, "HAND", "hand", "");
        _mint(NECK_NFT, "NECK", "neck", "");
        _mint(RING_NFT, "RING", "ring", "");
    }

    function coreName() public view override returns (string memory) {
        return _name;
    }

    function getSubTokens(uint256 tokenId) public view returns (uint256[] memory){
        SynthesizedToken[] memory tokens = synthesizedTokens[tokenId];
        uint256[] memory subs = new uint256[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            subs[i] = tokens[i].id;
        }
        return subs;
    }

    function claim(uint256 tokenId) public nonReentrant {
        require(tokenId > 0 && tokenId < 7778, "Token ID invalid");
        _safeMint(_msgSender(), tokenId);
        _afterTokenMint(tokenId);
    }

    function ownerClaim(uint256 tokenId) public nonReentrant onlyOwner {
        require(tokenId > 7777 && tokenId < 8001, "Token ID invalid");
        _safeMint(owner(), tokenId);
        _afterTokenMint(tokenId);
    }

    function combine(
        uint256 tokenId,
        uint256[] calldata subIds
    ) public {
        require(ownerOf(tokenId) == _msgSender(), "Legoot: caller is not token owner");
        require(primaryAttributeOf(tokenId) == LEGOOT_NFT, "Legoot: only support legoot combine");

        for (uint i = 0; i < subIds.length; i++) {
            require(ownerOf(subIds[i]) == _msgSender(), "Legoot: caller is not sub token owner");
            uint256 nft_attr = primaryAttributeOf(subIds[i]);
            require(nft_attr != LEGOOT_NFT, "Legoot: not support combine between legoots");
            for (uint j = 0; j < synthesizedTokens[tokenId].length; j ++) {
                uint256 id = synthesizedTokens[tokenId][j].id;
                require(nft_attr != primaryAttributeOf(id), "Legoot: duplicate sub token type");
            }
            _transfer(_msgSender(), address(this), subIds[i]);
            _recordSynthesized(_msgSender(), tokenId, subIds[i]);
        }
    }

    function separate(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Legoot: caller is not token owner nor approved");
        require(primaryAttributeOf(tokenId) == LEGOOT_NFT, "Legoot: only support legoot separate");

        SynthesizedToken[] storage subs = synthesizedTokens[tokenId];
        require(subs.length > 0, "Legoot: not synthesized token");
        for (uint256 i = 0; i < subs.length; i++) {
            if (subs[i].id > 0 && subs[i].owner != address(0)) {
                _transfer(address(this), subs[i].owner, subs[i].id);
            }
        }
        delete synthesizedTokens[tokenId];
    }

    function separateOne(uint256 tokenId, uint256 subId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Legoot: caller is not token owner nor approved");
        require(primaryAttributeOf(tokenId) == LEGOOT_NFT, "Legoot: only support legoot separate");

        uint idx = _findByValue(synthesizedTokens[tokenId], subId);
        SynthesizedToken storage token = synthesizedTokens[tokenId][idx];
        _transfer(address(this), token.owner, token.id);
        delete synthesizedTokens[tokenId][idx];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (primaryAttributeOf(tokenId) == LEGOOT_NFT) {
            SynthesizedToken[] storage subs = synthesizedTokens[tokenId];
            for (uint256 i = 0; i < subs.length; i++) {
                if (subs[i].id > 0) {
                    subs[i].owner = to;
                }
            }
        }
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[4] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = string(abi.encodePacked(symbol(primaryAttributeOf(tokenId)), ' #', tokenId.toString()));

        parts[2] = getImageText(tokenId, 20);

        parts[3] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3]));
        string memory attributes = getAttributes(tokenId);
        if (synthesizedTokens[tokenId].length > 0) {
            attributes = string(abi.encodePacked(attributes, ',{"trait_type":"SYNTHETIC","value":"true"}'));
        }

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', symbol(primaryAttributeOf(tokenId)), ' #', tokenId.toString(), '", "description": "Legoot is the first assembly toy that can be freely disassembled and assembled any  times you want. It is a true NFT LEGO, players can freely assemble and disassemble their own legoot parts and sell each part or the whole legoot individually! Not only that, players can mount legoot to metacore for NFT digital identity purposes. This incredible capability is supported by EIP-3664.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '","attributes":[', attributes, ']}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }

    function getImageText(uint256 tokenId, uint256 pos) public view returns (string memory) {
        bytes memory text = bytes(tokenText(tokenId, false));
        if (text.length > 0) {
            pos += 20;
            text = abi.encodePacked('</text><text x="10" y="', pos.toString(), '" class="base">', text);
        }
        SynthesizedToken[] memory tokens = synthesizedTokens[tokenId];
        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i].id > 0) {
                pos += 20;
                text = abi.encodePacked(text, '</text><text x="10" y="', pos.toString(), '" class="base">');
                text = abi.encodePacked(text, tokenText(tokens[i].id, true));
            }
        }
        return string(text);
    }

    function tokenTexts(uint256 tokenId) public view virtual override returns (string memory) {
        return tokenText(tokenId, false);
    }

    function tokenText(uint256 tokenId, bool prefix) internal view returns (string memory) {
        uint256 nft_id = primaryAttributeOf(tokenId);
        string memory text = "";
        if (nft_id == WEAPON_NFT) {
            text = getWeapon(tokenId, prefix);
        } else if (nft_id == CHEST_NFT) {
            text = getChest(tokenId, prefix);
        } else if (nft_id == HEAD_NFT) {
            text = getHead(tokenId, prefix);
        } else if (nft_id == WAIST_NFT) {
            text = getWaist(tokenId, prefix);
        } else if (nft_id == FOOT_NFT) {
            text = getFoot(tokenId, prefix);
        } else if (nft_id == HAND_NFT) {
            text = getHand(tokenId, prefix);
        } else if (nft_id == NECK_NFT) {
            text = getNeck(tokenId, prefix);
        } else if (nft_id == RING_NFT) {
            text = getRing(tokenId, prefix);
        }
        return text;
    }

    function getAttributes(uint256 tokenId) public view returns (string memory) {
        bytes memory data = bytes(tokenAttributes(tokenId));
        SynthesizedToken[] memory tokens = synthesizedTokens[tokenId];
        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i].id > 0) {
                if (data.length > 0) {
                    data = abi.encodePacked(data, ',', tokenAttributes(tokens[i].id));
                } else {
                    data = bytes(tokenAttributes(tokens[i].id));
                }
            }
        }
        return string(data);
    }

    function tokenAttributes(uint256 tokenId) public view virtual override returns (string memory) {
        string memory text = tokenText(tokenId, false);
        if (bytes(text).length == 0) {
            return "";
        }

        uint256 nft_id = primaryAttributeOf(tokenId);
        string memory keyPrefix = name(nft_id);
        if (nft_id == WEAPON_NFT) {
            return pluckAttribute(tokenId, keyPrefix, ILootData(LOOTDATA).getWeapons());
        } else if (nft_id == CHEST_NFT) {
            return pluckAttribute(tokenId, keyPrefix, ILootData(LOOTDATA).getChest());
        } else if (nft_id == HEAD_NFT) {
            return pluckAttribute(tokenId, keyPrefix, ILootData(LOOTDATA).getHead());
        } else if (nft_id == WAIST_NFT) {
            return pluckAttribute(tokenId, keyPrefix, ILootData(LOOTDATA).getWaist());
        } else if (nft_id == FOOT_NFT) {
            return pluckAttribute(tokenId, keyPrefix, ILootData(LOOTDATA).getFoot());
        } else if (nft_id == HAND_NFT) {
            return pluckAttribute(tokenId, keyPrefix, ILootData(LOOTDATA).getHand());
        } else if (nft_id == NECK_NFT) {
            return pluckAttribute(tokenId, keyPrefix, ILootData(LOOTDATA).getNecklaces());
        } else if (nft_id == RING_NFT) {
            return pluckAttribute(tokenId, keyPrefix, ILootData(LOOTDATA).getRings());
        } else {
            return "";
        }
    }

    function pluckAttribute(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        string[] memory suffixes = ILootData(LOOTDATA).getSuffixes();
        string[] memory namePrefixes = ILootData(LOOTDATA).getNamePrefixes();
        string[] memory nameSuffixes = ILootData(LOOTDATA).getNameSuffixes();

        uint256 rand = random(string(abi.encodePacked(keyPrefix, tokenId.toString())));
        string memory output = sourceArray[rand % sourceArray.length];

        bytes memory data = _concatAttribute(keyPrefix, 'NAME', output);
        data = abi.encodePacked(data, ',', _concatAttribute(keyPrefix, 'ID', tokenId.toString()));
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

    function getWeapon(uint256 tokenId, bool prefix) public view returns (string memory) {
        if (prefix) {
            return string(abi.encodePacked('[weapon] ', ILoot(LOOT).getWeapon(tokenId)));
        } else {
            return ILoot(LOOT).getWeapon(tokenId);
        }
    }

    function getChest(uint256 tokenId, bool prefix) public view returns (string memory){
        if (prefix) {
            return string(abi.encodePacked('[chest] ', ILoot(LOOT).getChest(tokenId)));
        } else {
            return ILoot(LOOT).getChest(tokenId);
        }
    }

    function getHead(uint256 tokenId, bool prefix) public view returns (string memory){
        if (prefix) {
            return string(abi.encodePacked('[head] ', ILoot(LOOT).getHead(tokenId)));
        } else {
            return ILoot(LOOT).getHead(tokenId);
        }
    }

    function getWaist(uint256 tokenId, bool prefix) public view returns (string memory){
        if (prefix) {
            return string(abi.encodePacked('[waist] ', ILoot(LOOT).getWaist(tokenId)));
        } else {
            return ILoot(LOOT).getWaist(tokenId);
        }
    }

    function getFoot(uint256 tokenId, bool prefix) public view returns (string memory){
        if (prefix) {
            return string(abi.encodePacked('[foot] ', ILoot(LOOT).getFoot(tokenId)));
        } else {
            return ILoot(LOOT).getFoot(tokenId);
        }
    }

    function getHand(uint256 tokenId, bool prefix) public view returns (string memory){
        if (prefix) {
            return string(abi.encodePacked('[hand] ', ILoot(LOOT).getHand(tokenId)));
        } else {
            return ILoot(LOOT).getHand(tokenId);
        }
    }

    function getNeck(uint256 tokenId, bool prefix) public view returns (string memory){
        if (prefix) {
            return string(abi.encodePacked('[neck] ', ILoot(LOOT).getNeck(tokenId)));
        } else {
            return ILoot(LOOT).getNeck(tokenId);
        }
    }

    function getRing(uint256 tokenId, bool prefix) public view returns (string memory) {
        if (prefix) {
            return string(abi.encodePacked('[ring] ', ILoot(LOOT).getRing(tokenId)));
        } else {
            return ILoot(LOOT).getRing(tokenId);
        }
    }

    function _afterTokenMint(uint256 tokenId) internal virtual {
        attach(tokenId, LEGOOT_NFT, 1, bytes("legoot"), true);
        uint256 id = _totalSupply + (tokenId - 1) * 8 + 1;
        // WEAPON
        _mintSubToken(WEAPON_NFT, tokenId, id);
        // CHEST
        _mintSubToken(CHEST_NFT, tokenId, id + 1);
        // HEAD
        _mintSubToken(HEAD_NFT, tokenId, id + 2);
        // WAIST
        _mintSubToken(WAIST_NFT, tokenId, id + 3);
        // FOOT
        _mintSubToken(FOOT_NFT, tokenId, id + 4);
        // HAND
        _mintSubToken(HAND_NFT, tokenId, id + 5);
        // NECK
        _mintSubToken(NECK_NFT, tokenId, id + 6);
        // RING
        _mintSubToken(RING_NFT, tokenId, id + 7);
    }

    function _mintSubToken(uint256 attr, uint256 tokenId, uint256 subId) internal virtual {
        _mint(address(this), subId);
        attach(subId, attr, 1, bytes(""), true);
        _recordSynthesized(_msgSender(), tokenId, subId);
    }

    function _recordSynthesized(address owner, uint256 tokenId, uint256 subId) internal {
        synthesizedTokens[tokenId].push(SynthesizedToken(owner, subId));
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

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
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
