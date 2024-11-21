// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {Box} from "../src/Box.sol";
import {Timelock} from "../src/Timelock.sol";
import {GovToken} from "../src/GovToken.sol";

contract MyGovernorTest is Test {
    MyGovernor governor;
    Box box;
    Timelock timelock;
    GovToken govToken;

    address public USER = makeAddr("user");
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    // uint256 public constant VOTING_DELAY = 1; // # of blocks until vote is active
    uint256 public VOTING_DELAY; // 初期化はsetup関数内で
    uint256 public constant MIN_DELAY = 3600; // 1 hour after a vote passes
    uint256 public constant VOTING_PERIOD = 50400;

    address[] proposers;
    address[] executors;
    bytes[] calldatas;
    address[] targets;
    uint256[] values;


    function setUp() public {
        govToken = new GovToken();
        govToken.mint(USER, INITIAL_SUPPLY);

        vm.startPrank(USER);
        govToken.delegate(USER);
        timelock = new Timelock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(govToken, timelock);

        VOTING_DELAY = governor.votingDelay(); // governorを初期化した後に取得
        // ロール識別子を取得
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        // bytes32 adminRole = timelock.TIMELOCK_ADMIN_ROLE(); // TimelockController.sol/TIMELOCK_ADMIN_ROLEが定義されていない
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE(); // AccessControl.DEFAULT_ADMIN_ROLEを使用、
        // ロールの付与
        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        // 　ユーザーから管理者ロールを削除
        timelock.revokeRole(adminRole, USER);
        vm.stopPrank();

        box = new Box();
        // Boxコントラクトの所有権を移転、Boxの操作はガバナンスプロセスを通じてのみ可能に
        box.transferOwnership(address(timelock));

    }

    function testCantUpdateBoxWithoutGovernance() public{
        vm.expectRevert();
        box.store(1);
    }

    function testGovernanceUpdatesBox() public {
        uint256 valueToStore = 888;
        string memory description = "store 1 in Box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);

        calldatas.push(encodedFunctionCall);
        values.push(0);
        targets.push(address(box));
        // 1. Propose
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        // View the State
        console.log("Proposal State 1: ", uint256(governor.state(proposalId)));
        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);
        console.log("Proposal State 2: ", uint256(governor.state(proposalId)));
        // 2. Vote
        string memory reason = "cuz blue frog is cool";
        // Vote Types derived from GovernorCountingSimple:
        // enum VoteType { // GovernorCountingSimple.sol
        //   Against, 0
        //   For, 1
        //   Abstain 2
        //}
        uint8 voteWay = 1; // voting Yes
        vm.prank(USER);
        governor.castVoteWithReason(proposalId, voteWay, reason);
        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        // 3. Queue the Proposal
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(targets, values, calldatas, descriptionHash);
        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);
        

        // 4. Execute the Proposal
        governor.execute(targets, values, calldatas, descriptionHash);
        console.log("Box Value: ", box.getNumber()); // retrieve　→ getNumber
        assert(box.getNumber() == valueToStore);
    }
}