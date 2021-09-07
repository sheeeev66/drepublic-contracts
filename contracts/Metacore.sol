// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "./ERC3664/extensions/ERC3664Combinable.sol";
import "./Synthetic/ISynthetic721.sol";

contract Metacore is ERC3664Combinable, ERC721Enumerable, ReentrancyGuard, Ownable {
    using Strings for uint256;
    using SafeMath for uint256;

    uint256 private _curTokenId = 0;

    mapping(address => uint256[]) private syntheableTokens;

    uint256 public constant METACORE = 1;

    constructor() ERC3664Combinable() ERC721("Metacore Identity System", "MIS") Ownable() {
        _mint(METACORE, "Metacore", "MetaName", "");
    }

    function getNextTokenID() public view returns (uint256) {
        return _curTokenId.add(1);
    }

    function claim(string memory name) public nonReentrant {
        require(getNextTokenID() <= 8000, "Metacore: reached the maximum number of claim");

        _curTokenId += 1;
        _safeMint(_msgSender(), _curTokenId);
        attach(_curTokenId, METACORE, 1, bytes(name));
        setRawAttribute(_curTokenId, METACORE);
    }

    function combine(
        uint256 tokenId,
        address[] calldata subTokens,
        uint256[] calldata subIds
    ) public {
        require(subTokens.length == subIds.length, "Metacore: subTokens and subIds length not match");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Metacore: caller is not token owner nor approved");
        require(getRawAttribute(tokenId) == METACORE, "Metacore: invalid tokenId only Metacore can be synthesized");

        for (uint256 i = 0; i < subTokens.length; i++) {
            // TODO 注册 interface
            ISynthetic721 sContract = ISynthetic721(subTokens[i]);
            require(sContract.isApprovedForAll(sContract.ownerOf(tokenId), _msgSender()),
                "Metacore: caller is not sub token owner nor approved");

            sContract.transferFrom(_msgSender(), address(this), subIds[i]);
            super.combine(tokenId, subTokens[i], subIds[i]);
        }
    }

    function separate(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Metacore: caller is not token owner nor approved");
        require(getRawAttribute(tokenId) == METACORE, "Metacore: invalid tokenId only Metacore can be synthesized");

        SynthesizedToken[] memory subs = getSynthesizedTokens(tokenId);
        require(subs.length > 0, "Metacore: not synthesized token");
        for (uint256 i = 0; i < subs.length; i++) {
            ISynthetic721(subs[i].token).transferFrom(address(this), subs[i].owner, subs[i].id);
            if (getSynthesizedTokens(subs[i].id).length > 0) {
                separate(subs[i].id);
            }
        }
        delete synthesizedTokens[tokenId];
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[4] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = string(abi.encodePacked(name(getRawAttribute(tokenId)), ' #', tokenId.toString(), '</text><text x="10" y="40" class="base">'));

        parts[2] = getImageText(0, tokenId, 40);

        parts[3] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3]));
        string memory attributes = getAttributes(0, tokenId);

        if (getSynthesizedTokens(tokenId).length > 0) {
            attributes = string(abi.encodePacked(attributes, ',{"trait_type":"SYNTHETIC","value":"true"}'));
        } else {
            attributes = string(abi.encodePacked(attributes, ',{"trait_type":"SYNTHETIC","value":"false"}'));
        }

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', name(getRawAttribute(tokenId)), ' #', tokenId.toString(), '", "description": "MetaCore is an identity system which can make all metaverse citizens join into different metaverses by using same MetaCore Identity. The first modular NFT with MetaCore at its core, with arbitrary attributes addition and removal, freely combine and divide each components. Already adapted to multiple metaverse blockchain games. FUTURE IS COMMING", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '","attributes":[', attributes, ']}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }

    function getImageText(uint256 mainId, uint256 subId, uint256 pos) internal view returns (string memory) {
        bytes memory text;
        if (_exists(subId) && mainId == 0) {
            text = textOf(subId, getRawAttribute(subId));
        } else {
            string[] memory subTexts = ISynthetic721(subTokens[subId][mainId]).tokenTexts(subId);
            for (uint i = 0; i < subTexts.length; i++) {
                uint256 newPos = 20 * (i + 1) + pos;
                text = abi.encodePacked(text, '</text><text x="10" y="', newPos.toString(), '" class="base">');
                text = abi.encodePacked(text, subTexts[i]);
            }
        }
        return string(abi.encodePacked(text, getSubImageText(subId, pos)));
    }

    function getSubImageText(uint256 tokenId, uint256 pos) internal view returns (bytes memory) {
        bytes memory text = "";
        SynthesizedToken[] memory tokens = getSynthesizedTokens(tokenId);
        for (uint i = 0; i < tokens.length; i++) {
            uint256 newPos = 20 * (i + 1) + pos;
            text = abi.encodePacked(text, '</text><text x="10" y="', newPos.toString(), '" class="base">');
            text = abi.encodePacked(text, getImageText(tokenId, tokens[i].id, newPos));
        }
        return text;
    }

    function getAttributes(uint256 mainId, uint256 subId) internal view returns (string memory) {
        bytes memory data;
        if (_exists(subId) && mainId == 0) {
            data = bytes(super.tokenAttributes(subId));
        } else {
            data = abi.encodePacked(data, ',', ISynthetic721(subTokens[subId][mainId]).tokenAttributes(subId));
        }

        data = abi.encodePacked(data, getSubTokenAttributes(subId));
        return string(data);
    }

    function getSubTokenAttributes(uint256 tokenId) internal view returns (bytes memory) {
        bytes memory data = "";
        SynthesizedToken[] memory tokens = getSynthesizedTokens(tokenId);
        for (uint i = 0; i < tokens.length; i++) {
            data = abi.encodePacked(data, ',');
            data = abi.encodePacked(data, getAttributes(tokenId, tokens[i].id));
        }
        return data;
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
