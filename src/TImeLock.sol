// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract Timelock is TimelockController { // TimelockControllerはTimelockクラスに継承されている
    /**
     * @notice Create a new Timelock controller
     * @param minDelay Minimum delay for timelock executions
     * @param proposers List of addresses that can propose new transactions
     * @param executors List of addresses that can execute transactions
     */
     // minDelay is how long you have to wait before executing
     // proposers is the list of address that can propose
     //executors is the list of address that can execute
     // TimelockController.solのstruct 
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors) 
        TimelockController(minDelay, proposers, executors, msg.sender)
    {}
}