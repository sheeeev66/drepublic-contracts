// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "./ERC3664/extensions/ERC3664CrossSynthetic.sol";
import "./Synthetic/ISynthetic721.sol";

interface ICustomMetadata {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract Metacore is ERC3664CrossSynthetic, ERC721Enumerable, ReentrancyGuard, Ownable {
    using Strings for uint256;
    using SafeMath for uint256;

    uint256 private constant METANAME = 1;

    uint256 private _totalSupply = 8000;

    uint256 private _curTokenId = 0;

    mapping(address => bool) private _authNFTs;

    address private _customURI = address(0);

    constructor() ERC3664CrossSynthetic() ERC721("Metacore Identity System", "Metacore") Ownable() {
        _authNFTs[0x0927C6A8A35b1A62531fEB8D5eFbEF23a09F39a1] = true;
        _mint(METANAME, "Metaname", "MetaName", "");
    }

    function getNextTokenID() public view returns (uint256) {
        return _curTokenId.add(1);
    }

    function increaseIssue(uint256 supply) public onlyOwner {
        _totalSupply = supply;
    }

    function setCustomMetadata(address uri) public onlyOwner {
        _customURI = uri;
    }

    function setAuthNFTs(address nft, bool enable) public onlyOwner {
        _authNFTs[nft] = enable;
    }

    function claim(string memory name) public nonReentrant {
        require(getNextTokenID() <= _totalSupply, "Metacore: reached the maximum number of claim");

        _curTokenId += 1;
        _safeMint(_msgSender(), _curTokenId);
        attach(_curTokenId, METANAME, 1, bytes(name), true);
    }

    function combine(
        uint256 tokenId,
        address subToken,
        uint256 subId
    ) public {
        require(ownerOf(tokenId) == _msgSender(), "Metacore: caller is not token owner");
        require(_authNFTs[subToken], "Metacore: invalid nft address");
        ISynthetic721 sContract = ISynthetic721(subToken);
        require(sContract.getApproved(subId) == address(this),
            "Metacore: caller is not sub token owner nor approved");

        sContract.transferFrom(_msgSender(), address(this), subId);
        recordSynthesized(tokenId, subToken, subId);
    }

    function separate(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Metacore: caller is not token owner nor approved");

        SynthesizedToken[] memory subs = getSynthesizedTokens(tokenId);
        require(subs.length > 0, "Metacore: not synthesized token");
        for (uint256 i = 0; i < subs.length; i++) {
            if (subs[i].id > 0 && subs[i].owner != address(0)) {
                ISynthetic721(subs[i].token).transferFrom(address(this), subs[i].owner, subs[i].id);
            }
        }
        delete synthesizedTokens[tokenId];
    }

    function separateOne(uint256 tokenId, uint256 subId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Metacore: caller is not token owner nor approved");

        uint idx = _findByValue(synthesizedTokens[tokenId], subId);
        SynthesizedToken storage token = synthesizedTokens[tokenId][idx];
        ISynthetic721(token.token).transferFrom(address(this), token.owner, token.id);
        delete synthesizedTokens[tokenId][idx];
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        if (_customURI != address(0)) {
            return ICustomMetadata(_customURI).tokenURI(tokenId);
        }
        return coreTokenURI(tokenId);
    }

    function coreTokenURI(uint256 tokenId) public view returns (string memory) {
        string[4] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = string(abi.encodePacked('Metacore #', tokenId.toString(), '</text><text x="10" y="40" class="base">'));

        parts[2] = string(textOf(tokenId, METANAME));

        parts[3] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3]));
        string memory attributes = getAttributes(tokenId);

        if (getSynthesizedTokens(tokenId).length > 0) {
            attributes = string(abi.encodePacked(attributes, ',{"trait_type":"SYNTHETIC","value":"true"}'));
        }

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Metacore #', tokenId.toString(), '", "description": "MetaCore is an identity system which can make all metaverse citizens join into different metaverses by using same MetaCore Identity. The first modular NFT with MetaCore at its core, with arbitrary attributes addition and removal, freely combine and divide each components. Already adapted to multiple metaverse blockchain games. FUTURE IS COMMING", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '","attributes":[', attributes, ']}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }

    function getAttributes(uint256 tokenId) public view returns (string memory) {
        bytes memory data = bytes(super.tokenAttributes(tokenId));
        SynthesizedToken[] memory tokens = synthesizedTokens[tokenId];
        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i].id > 0) {
                data = abi.encodePacked(data, ',', _concatAttribute(ISynthetic721(tokens[i].token).coreName(), tokens[i].id.toString()));
            }
        }
        return string(data);
    }

    function _concatAttribute(string memory key, string memory value) internal pure returns (bytes memory)  {
        return abi.encodePacked('{"trait_type":"', key, '","value":"', value, '"}');
    }

    function _findByValue(SynthesizedToken[] storage values, uint256 value) internal view returns (uint) {
        uint i = 0;
        while (values[i].id != value) {
            i++;
        }
        return i;
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
