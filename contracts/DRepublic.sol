// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

/**
 * @title ERC20Decimals
 * @dev Implementation of the ERC20Decimals. Extension of {ERC20} that adds decimals storage slot.
 */
contract DRepublic is ERC20 {
    uint8 immutable private _decimals = 18;
    uint256 private _totalSupply = 10000000000000 * 10 ** 18;
    
    /**
     * @dev Sets the value of the `decimals`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor (string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(_msgSender(), _totalSupply);
    }
    
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
