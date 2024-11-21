// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "@openzeppelin/utils/Nonces.sol";

contract GovToken is ERC20, ERC20Permit, ERC20Votes {
    constructor() ERC20("GovToken", "GT") ERC20Permit("MyToken") {}

    // The following functions are overrides required by Solidity.
    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    // function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
    //     super._afterTokenTransfer(from, to, amount);
    // }
    
    // ERC20の_mintはvirtuaalとして定義されていないのでオーバーライドできない
    // function _mint(address to, uint256 amount) internal override(ERC20, ERC20Votes) {
    //     super._mint(to, amount);
    // }

    // function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
    //     super._burn(account, amount);
    // }

}