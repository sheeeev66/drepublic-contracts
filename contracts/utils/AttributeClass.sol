// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract AttributeClass {
    enum AttrClass {
        Generic,
        Upgradable,
        Transferable,
        Evolutive
    }

    AttrClass private _class;

    constructor (AttrClass class_) {
        _class = class_;
    }

    /**
     * @dev Returns the class of the attribute.
     */
    function class() public view virtual returns (AttrClass) {
        return _class;
    }
}
