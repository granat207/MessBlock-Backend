// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MessBlock} from "../src/MessBlock.sol";

contract MessBlockChatsTest is Test {
    
    address public david = makeAddr("david"); 
    MessBlock public messBlock;

    function setUp() public {
        messBlock = new MessBlock(); 
    }

    function test_createChat() public {
        vm.startPrank(david);
    }

}
