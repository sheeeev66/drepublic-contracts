// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/utils/Strings.sol";

contract DragontarData {
    using Strings for uint256;

    string[] private bodys = [
        "001",
        "002",
        "003",
        "004",
        "005", // 1
        "007", // 2
        "006", // 4
        "008" // 5
    ];

    string[] private dresses = [
        "001",
        "002",
        "003", // 3
        "004" // 4
    ];

    string[] private necks = [
        "001",
        "002", // 2
        "003",
        "004", // 3
        "005",
        "006",
        "007" // 4
    ];

    string[] private eyes = [
        "001",
        "002",
        "003",
        "004",
        "005",
        "006", // 1
        "007",
        "008",
        "019", // 2
        "013",
        "015",
        "016",
        "017",
        "018", // 3
        "009",
        "010",
        "011",
        "014", //4
        "012" //5
    ];

    string[] private ears = [
        "004",
        "005",
        "006",
        "007",
        "008",
        "009", // 3
        "002",
        "003", //4
        "001" // 5
    ];

    string[] private mouths = [
        "001",
        "002",
        "003",
        "004",
        "005",
        "006",
        "007", // 1
        "008" // 5
    ];

    string[] private decorates = [
        "001",
        "002",
        "003",
        "004",
        "005",
        "006",
        "016", // 2
        "007",
        "008",
        "009",
        "015",
        "017", // 3
        "010",
        "011",
        "014",
        "018",
        "019", // 4
        "012",
        "013" // 5
    ];

    string[] private hats = [
        "003",
        "019",
        "021",
        "025",
        "026", // 2
        "001",
        "002",
        "020", // 3
        "005",
        "008",
        "009",
        "013",
        "014",
        "023",
        "024", // 4
        "007",
        "010",
        "011",
        "017",
        "018",
        "022",
        "027", // 5
        "015",
        "016" // 6
    ];

    string[] private teeth = [
        "001",
        "004", // 1
        "002",
        "003" // 5
    ];

    struct Rarity {
        uint8 randV;
        uint8 num;
        uint8 score;
    }

    Rarity[] private bodyRarity;

    Rarity[] private dressRarity;

    Rarity[] private neckRarity;

    Rarity[] private eyeRarity;

    Rarity[] private earRarity;

    Rarity[] private mouthRarity;

    Rarity[] private decorateRarity;

    Rarity[] private hatRarity;

    Rarity[] private toothRarity;

    constructor() {
        bodyRarity.push(Rarity(70, 5, 1));
        bodyRarity.push(Rarity(90, 1, 2));
        bodyRarity.push(Rarity(98, 1, 4));
        bodyRarity.push(Rarity(100, 1, 5));

        dressRarity.push(Rarity(80, 0, 0));
        dressRarity.push(Rarity(95, 3, 3));
        dressRarity.push(Rarity(100, 1, 4));

        neckRarity.push(Rarity(60, 0, 0));
        neckRarity.push(Rarity(80, 2, 2));
        neckRarity.push(Rarity(95, 2, 3));
        neckRarity.push(Rarity(100, 3, 4));

        eyeRarity.push(Rarity(60, 6, 1));
        eyeRarity.push(Rarity(80, 3, 2));
        eyeRarity.push(Rarity(90, 5, 3));
        eyeRarity.push(Rarity(97, 4, 4));
        eyeRarity.push(Rarity(100, 1, 5));

        earRarity.push(Rarity(70, 0, 0));
        earRarity.push(Rarity(85, 6, 3));
        earRarity.push(Rarity(97, 2, 4));
        earRarity.push(Rarity(100, 1, 5));

        mouthRarity.push(Rarity(90, 7, 1));
        mouthRarity.push(Rarity(100, 1, 5));

        decorateRarity.push(Rarity(70, 0, 0));
        decorateRarity.push(Rarity(87, 7, 2));
        decorateRarity.push(Rarity(97, 5, 3));
        decorateRarity.push(Rarity(99, 5, 4));
        decorateRarity.push(Rarity(100, 2, 5));

        hatRarity.push(Rarity(40, 0, 0));
        hatRarity.push(Rarity(65, 5, 2));
        hatRarity.push(Rarity(85, 3, 3));
        hatRarity.push(Rarity(93, 7, 4));
        hatRarity.push(Rarity(99, 7, 5));
        hatRarity.push(Rarity(100, 2, 6));

        toothRarity.push(Rarity(90, 2, 1));
        toothRarity.push(Rarity(100, 2, 5));
    }

    function getBackground(
        uint256 /*tokenId*/
    ) public pure returns (string memory, uint8) {
        return ("000", 0);
    }

    function getBody(uint256 tokenId)
        public
        view
        returns (string memory, uint8)
    {
        return randomDraw(tokenId, "BODY", bodys, bodyRarity);
    }

    function getDress(uint256 tokenId)
        public
        view
        returns (string memory, uint8)
    {
        return randomDraw(tokenId, "DRESS", dresses, dressRarity);
    }

    function getNeck(uint256 tokenId)
        public
        view
        returns (string memory, uint8)
    {
        return randomDraw(tokenId, "NECK", necks, neckRarity);
    }

    function getEye(uint256 tokenId)
        public
        view
        returns (string memory, uint8)
    {
        return randomDraw(tokenId, "EYE", eyes, eyeRarity);
    }

    function getEar(uint256 tokenId)
        public
        view
        returns (string memory, uint8)
    {
        return randomDraw(tokenId, "EAR", ears, earRarity);
    }

    function getMouth(uint256 tokenId)
        public
        view
        returns (string memory, uint8)
    {
        return randomDraw(tokenId, "MOUTH", mouths, mouthRarity);
    }

    function getDecorate(uint256 tokenId)
        public
        view
        returns (string memory, uint8)
    {
        return randomDraw(tokenId, "DECORATE", decorates, decorateRarity);
    }

    function getHat(uint256 tokenId)
        public
        view
        returns (string memory, uint8)
    {
        return randomDraw(tokenId, "HAT", hats, hatRarity);
    }

    function getTooth(uint256 tokenId)
        public
        view
        returns (string memory, uint8)
    {
        return randomDraw(tokenId, "TOOTH", teeth, toothRarity);
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function randomDraw(
        uint256 tokenId,
        string memory keyPrefix,
        string[] memory sourceArray,
        Rarity[] memory rareArray
    ) internal pure returns (string memory id, uint8 score) {
        uint256 rand = random(
            string(abi.encodePacked(keyPrefix, tokenId.toString()))
        );
        uint256 place = rand % 100;
        uint8 idx = 0;
        for (uint256 i = 0; i < rareArray.length; i++) {
            if (place < rareArray[i].randV) {
                if (0 == rareArray[i].num) {
                    return ("000", 0);
                }
                uint256 n = rand % rareArray[i].num;
                id = sourceArray[idx + n];
                score = rareArray[i].score;
                break;
            }
            idx += rareArray[i].num;
        }
        return (id, score);
    }
}
