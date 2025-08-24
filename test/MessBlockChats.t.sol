// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MessBlock} from "../src/MessBlock.sol";

contract MessBlockChatsTest is Test {
    MessBlock public messBlock;

    function setUp() public {
        messBlock = new MessBlock(); 
    }

}
