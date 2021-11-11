// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "../ERC3664/extensions/ERC3664TextBased.sol";
import "../ERC3664/extensions/ERC3664Transferable.sol";
import "../ERC721/ERC721AutoId.sol";
import "../utils/Base64.sol";

interface IDragontarData {
    function getBackground(uint256 tokenId)
        external
        pure
        returns (string memory, uint8);

    function getBody(uint256 tokenId)
        external
        view
        returns (string memory, uint8);

    function getDress(uint256 tokenId)
        external
        view
        returns (string memory, uint8);

    function getNeck(uint256 tokenId)
        external
        view
        returns (string memory, uint8);

    function getEye(uint256 tokenId)
        external
        view
        returns (string memory, uint8);

    function getEar(uint256 tokenId)
        external
        view
        returns (string memory, uint8);

    function getMouth(uint256 tokenId)
        external
        view
        returns (string memory, uint8);

    function getDecorate(uint256 tokenId)
        external
        view
        returns (string memory, uint8);

    function getHat(uint256 tokenId)
        external
        view
        returns (string memory, uint8);

    function getTooth(uint256 tokenId)
        external
        view
        returns (string memory, uint8);
}

contract Dragontar is
    ERC3664TextBased,
    ERC3664Transferable,
    ERC721Enumerable,
    ReentrancyGuard,
    Ownable
{
    using Strings for uint256;

    address private constant DragontarData =
        0x4B2Bb4b24221EaCe19F79E2aD5242218864d3f00;

    address private constant DragontarAttr =
        0xBFe36Fc35f1cB3781850F8C16B67e49A1F568826;

    string private _uri;

    uint256 private _curTokenId;

    // attrId => is splittable
    mapping(uint256 => bool) public splittableAttrs;

    constructor() ERC3664("") ERC721("DRepublic Dragontar", "Dragontar") {
        _uri = "http://www.cradles.io/dragontar/";

        splittableAttrs[3] = true;
        splittableAttrs[4] = true;
        splittableAttrs[6] = true;
        splittableAttrs[8] = true;
        splittableAttrs[9] = true;

        _mint(1, "", "background", "");
        _mint(2, "", "body", "");
        _mint(3, "", "dress", "");
        _mint(4, "", "neck", "");
        _mint(5, "", "eye", "");
        _mint(6, "", "ear", "");
        _mint(7, "", "mouth", "");
        _mint(8, "", "decorate", "");
        _mint(9, "", "hat", "");
        _mint(10, "", "tooth", "");
    }

    function setURI(string memory _newURI) external onlyOwner {
        _uri = _newURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC3664, ERC721Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(ERC3664TextBased).interfaceId ||
            interfaceId == type(ERC3664Transferable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function getCurrentTokenID() public view returns (uint256) {
        return _curTokenId;
    }

    function claim() external nonReentrant {
        _curTokenId += 1;
        _safeMint(_msgSender(), _curTokenId);

        string memory text;
        uint8 score;
        (text, score) = IDragontarData(DragontarData).getBackground(
            _curTokenId
        );
        attachWithText(_curTokenId, 1, uint256(score), bytes(text));
        (text, score) = IDragontarData(DragontarData).getBody(_curTokenId);
        attachWithText(_curTokenId, 2, uint256(score), bytes(text));
        (text, score) = IDragontarData(DragontarData).getDress(_curTokenId);
        attachWithText(_curTokenId, 3, uint256(score), bytes(text));
        (text, score) = IDragontarData(DragontarData).getNeck(_curTokenId);
        attachWithText(_curTokenId, 4, uint256(score), bytes(text));
        (text, score) = IDragontarData(DragontarData).getEye(_curTokenId);
        attachWithText(_curTokenId, 5, uint256(score), bytes(text));
        (text, score) = IDragontarData(DragontarData).getEar(_curTokenId);
        attachWithText(_curTokenId, 6, uint256(score), bytes(text));
        (text, score) = IDragontarData(DragontarData).getMouth(_curTokenId);
        attachWithText(_curTokenId, 7, uint256(score), bytes(text));
        (text, score) = IDragontarData(DragontarData).getDecorate(_curTokenId);
        attachWithText(_curTokenId, 8, uint256(score), bytes(text));
        (text, score) = IDragontarData(DragontarData).getHat(_curTokenId);
        attachWithText(_curTokenId, 9, uint256(score), bytes(text));
        (text, score) = IDragontarData(DragontarData).getTooth(_curTokenId);
        attachWithText(_curTokenId, 10, uint256(score), bytes(text));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Dragontar #',
                        tokenId.toString(),
                        '", "description": "DRepublic dragon avatar", "images": "',
                        _uri,
                        fullIdOf(tokenId),
                        '", "attributes":[',
                        printAttributes(tokenId),
                        "]}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function fullIdOf(uint256 tokenId) public view returns (string memory) {
        bytes memory data = "";
        uint256[] memory ma = attributesOf(tokenId);
        for (uint256 i = 0; i < ma.length; i++) {
            data = abi.encodePacked(data, textOf(tokenId, ma[i]));
        }
        return string(data);
    }

    function rarityOf(uint256 tokenId) public view returns (string memory) {
        uint256 score = 0;
        uint256[] memory ma = attributesOf(tokenId);
        for (uint256 i = 0; i < ma.length; i++) {
            score += balanceOf(tokenId, ma[i]);
        }
        if (score <= 12) {
            return "R";
        } else if (score <= 16) {
            return "SR";
        } else {
            return "SSR";
        }
    }

    function separateOne(uint256 tokenId, uint256 attrId) public {
        require(
            splittableAttrs[attrId],
            "Dragontar: the attribute cannot be split"
        );
        require(
            _hasAttr(tokenId, attrId),
            "Dragontar: token has not attached the attribute"
        );
        require(
            ERC721.ownerOf(tokenId) == _msgSender(),
            "Dragontar: caller is not token owner"
        );

        uint256 attrTokenId = getAttrTokenId(address(this), tokenId, attrId);
        _transfer(tokenId, attrTokenId, attrId);

        ERC721AutoId attrNFT = ERC721AutoId(DragontarAttr);
        if (attrNFT.exists(attrTokenId)) {
            require(
                attrNFT.ownerOf(attrTokenId) == address(this),
                "Dragontar: invalid attrTokenId owner"
            );
            attrNFT.transferFrom(address(this), _msgSender(), attrTokenId);
        } else {
            attrNFT.mintWithId(_msgSender(), attrTokenId);
        }
    }

    function combine(
        uint256 tokenId,
        uint256 attrTokenId,
        uint256 attrId
    ) public {
        require(
            splittableAttrs[attrId],
            "Dragontar: the attribute cannot be combine"
        );
        require(
            ERC721.ownerOf(tokenId) == _msgSender(),
            "Dragontar: caller is not token owner"
        );
        ERC721AutoId attrNFT = ERC721AutoId(DragontarAttr);
        require(
            attrNFT.ownerOf(attrTokenId) == _msgSender(),
            "Dragontar: caller is not attrToken owner"
        );
        require(
            _hasAttr(attrTokenId, attrId),
            "Dragontar: invalid attrTokenId"
        );
        require(
            !_hasAttr(tokenId, attrId),
            "Dragontar: token already attached the attribute"
        );

        _transfer(attrTokenId, tokenId, attrId);

        attrNFT.transferFrom(_msgSender(), address(this), attrTokenId);
    }

    function getAttrTokenId(
        address nftAddress,
        uint256 tokenId,
        uint256 attrId
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(nftAddress, tokenId, attrId)));
    }

    function approve(
        uint256 from,
        uint256 to,
        uint256 attrId
    ) public virtual override {
        require(
            ERC721.ownerOf(from) == _msgSender(),
            "Dragontar: caller is not token owner"
        );

        ERC3664Transferable.approve(from, to, attrId);
    }
}
