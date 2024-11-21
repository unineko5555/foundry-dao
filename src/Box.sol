// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable {
    uint256 private s_number;

    event NumberChanged(uint256 number);

    // openzeppelinの最新版では所有者を明示する必要あり。Ownable2Stepを使えばその必要なし。
    constructor() Ownable(msg.sender) {}

    function store(uint256 newNumber) public onlyOwner {
        s_number = newNumber;
        emit NumberChanged(newNumber);
    }

    function getNumber() external view returns (uint256) {
        return s_number;
    }

    // function retrieve() public view returns (uint256) {
    //     return s_number;
    // }
}