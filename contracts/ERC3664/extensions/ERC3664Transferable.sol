// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC3664.sol";
import "./IERC3664Transferable.sol";

/**
 * @dev Implementation of the {ERC3664Transferable} interface.
 */
abstract contract ERC3664Transferable is ERC3664, IERC3664Transferable {
    // attribute ID => from token ID => to token ID
    mapping(uint256 => mapping(uint256 => uint256)) private _allowances;

    /**
     * @dev See {IERC3664Transferable-isApproved}.
     */
    function isApproved(
        uint256 from,
        uint256 to,
        uint256 attrId
    ) public view virtual override returns (bool) {
        return _allowances[attrId][from] == to;
    }

    /**
     * @dev See {IERC3664Transferable-approve}.
     */
    function approve(
        uint256 from,
        uint256 to,
        uint256 attrId
    ) public virtual override {
        require(
            from != 0,
            "ERC3664Transferable: approve from the zero address"
        );
        require(to != 0, "ERC3664Transferable: approve to the zero address");
        require(
            _hasAttr(from, attrId),
            "ERC3664Transferable: sender not attached the attribute"
        );

        _allowances[attrId][from] = to;

        emit AttributeApproval(_msgSender(), from, to, attrId);
    }

    /**
     * @dev See {IERC3664Transferable-transferFrom}.
     */
    function transferFrom(
        uint256 from,
        uint256 to,
        uint256 attrId
    ) public virtual override {
        require(
            isApproved(from, to, attrId),
            "ERC3664Transferable: nft holder not approve the attribute to recipient"
        );
        _transfer(from, to, attrId);
    }

    function _transfer(
        uint256 from,
        uint256 to,
        uint256 attrId
    ) internal virtual {
        require(
            !_hasAttr(to, attrId),
            "ERC3664Transferable: recipient has attached the attribute"
        );

        address operator = _msgSender();
        uint256 amount = attrBalances[attrId][from];
        _beforeAttrTransfer(
            operator,
            from,
            to,
            _asSingletonArray(attrId),
            _asSingletonArray(amount),
            ""
        );

        attrBalances[attrId][to] = amount;
        delete attrBalances[attrId][from];
        delete _allowances[attrId][from];

        emit TransferSingle(operator, from, to, attrId, amount);
    }
}
