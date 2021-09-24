// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/AccessControlEnumerable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "openzeppelin-solidity/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

/**
 * @title ERC1155Tradable
 * ERC1155Tradable - ERC1155 contract has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol(), and totalSupply()
 */
contract ERC1155Tradable is ERC1155Burnable, AccessControlEnumerable {
    using Address for address;
    using Strings for uint256;
    using SafeMath for uint256;

    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => string) public customUri;

    // Contract name
    string public name;
    // Contract symbol
    string public symbol;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC1155(_uri) {
        name = _name;
        symbol = _symbol;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CREATOR_ROLE, _msgSender());
    }

    /**
     * @dev Returns the total quantity for a token ID
     * @param _id uint256 ID of the token to query
     * @return amount of token in existence
     */
    function totalSupply(uint256 _id) public view returns (uint256) {
        return tokenSupply[_id];
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     * @param _newURI New URI for all tokens
     */
    function setURI(string memory _newURI) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "ERC1155Tradable: must have creator role"
        );
        _setURI(_newURI);
    }

    /**
     * @dev Will update the base URI for the token
     * @param _tokenId The token to update. _msgSender() must be its creator.
     * @param _newURI New URI for the token.
     */
    function setCustomURI(uint256 _tokenId, string memory _newURI) public {
        require(
            creators[_tokenId] == _msgSender(),
            "ERC1155Tradable: only creator allowed"
        );

        customUri[_tokenId] = _newURI;
        emit URI(_newURI, _tokenId);
    }

    function creatorOf(uint256 _id) public view returns (address) {
        return creators[_id];
    }

    /**
     * @dev Creates a new token type and assigns _initialSupply to an address
     * NOTE: remove onlyOwner if you want third parties to create new tokens on
     *       your contract (which may change your IDs)
     * NOTE: The token id must be passed. This allows lazy creation of tokens or
     *       creating NFTs by setting the id's high bits with the method
     *       described in ERC1155 or to use ids representing values other than
     *       successive small integers. If you wish to create ids as successive
     *       small integers you can either subclass this class to count onchain
     *       or maintain the offchain cache of identifiers recommended in
     *       ERC1155 and calculate successive ids from that.
     * @param _initialOwner address of the first owner of the token
     * @param _id The id of the token to create (must not currenty exist).
     * @param _initialSupply amount to supply the first owner
     * @param _uri Optional URI for this token type
     */
    function create(
        address _initialOwner,
        uint256 _id,
        uint256 _initialSupply,
        string memory _uri
    ) public returns (uint256) {
        require(
            hasRole(CREATOR_ROLE, _msgSender()),
            "ERC1155Tradable: must have creator role"
        );
        require(!_exists(_id), "ERC1155Tradable: token _id already exists");

        creators[_id] = _msgSender();

        if (bytes(_uri).length > 0) {
            customUri[_id] = _uri;
            emit URI(_uri, _id);
        }

        _mint(_initialOwner, _id, _initialSupply, "");

        tokenSupply[_id] = _initialSupply;
        return _id;
    }

    /**
     * @dev Mints some amount of tokens to an address
     * @param _to          Address of the future owner of the token
     * @param _id          Token ID to mint
     * @param _quantity    Amount of tokens to mint
     * @param _data        Data to pass if receiver is contract
     */
    function mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) public virtual {
        require(
            creators[_id] == _msgSender() || hasRole(MINTER_ROLE, _msgSender()),
            "ERC1155Tradable: only creator or has minter role can mint"
        );

        _mint(_to, _id, _quantity, _data);
        tokenSupply[_id] = tokenSupply[_id].add(_quantity);
    }

    /**
     * @dev Mint tokens for each id in _ids
     * @param _to          The address to mint tokens to
     * @param _ids         Array of ids to mint
     * @param _quantities  Array of amounts of tokens to mint per id
     * @param _data        Data to pass if receiver is contract
     */
    function batchMint(
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _quantities,
        bytes memory _data
    ) public {
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 _id = _ids[i];
            require(
                creators[_id] == _msgSender() ||
                    hasRole(MINTER_ROLE, _msgSender()),
                "ERC1155Tradable: only creator or has minter role can mint"
            );
            uint256 quantity = _quantities[i];
            tokenSupply[_id] = tokenSupply[_id].add(quantity);
        }
        _mintBatch(_to, _ids, _quantities, _data);
    }

    /**
     * @notice Burn _quantity of tokens of a given id from msg.sender
     * @dev This will not change the current issuance tracked in _supplyManagerAddr.
     * @param _id     Asset id to burn
     * @param _quantity The amount to be burn
     */
    function burn(
        address _account,
        uint256 _id,
        uint256 _quantity
    ) public virtual override {
        super.burn(_account, _id, _quantity);

        tokenSupply[_id] = tokenSupply[_id].sub(_quantity);
    }

    /**
     * @notice Burn _quantities of tokens of given ids from msg.sender
     * @dev This will not change the current issuance tracked in _supplyManagerAddr.
     * @param _ids     Asset id to burn
     * @param _quantities The amount to be burn
     */
    function burnBatch(
        address _account,
        uint256[] calldata _ids,
        uint256[] calldata _quantities
    ) public virtual override {
        super.burnBatch(_account, _ids, _quantities);

        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 _id = _ids[i];
            uint256 quantity = _quantities[i];
            tokenSupply[_id] = tokenSupply[_id].sub(quantity);
        }
    }

    /**
     * @dev Change the creator address for given tokens
     * @param _to   Address of the new creator
     * @param _ids  Array of Token IDs to change creator
     */
    function setCreator(address _to, uint256[] memory _ids) public {
        require(_to != address(0), "ERC1155Tradable: invalid address.");
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            require(
                creators[id] == _msgSender(),
                "ERC1155Tradable: only creator allowed"
            );
            creators[id] = _to;
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns whether the specified token exists by checking to see if it has a creator
     * @param _id uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 _id) internal view returns (bool) {
        return creators[_id] != address(0);
    }

    function exists(uint256 _id) external view returns (bool) {
        return _exists(_id);
    }
}
