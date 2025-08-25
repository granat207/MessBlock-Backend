// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MessBlock} from "../src/MessBlock.sol";
import {MessBlockChats} from "../src/MessBlockChats.sol";

contract MessBlockChatsTest is Test {
    
    address public david = makeAddr("david"); 
    address public bob = makeAddr("bob"); 
    MessBlock public messBlock;

    function setUp() public {
        messBlock = new MessBlock(); 
    }
    
    //createChat tests
    function test_canCreateChat() public {
        vm.startPrank(david);
        messBlock.createChat(bob); 
        address[] memory chats = messBlock.getUserChats();
        assertEq(chats[0], bob);
		bytes memory chatHash_david_bob = messBlock.getChatKey(david, bob);
		assertNotEq(chatHash_david_bob.length, 0);
		bytes memory chatHash_bob_david = messBlock.getChatKey(bob, david);
		assertNotEq(chatHash_bob_david.length, 0);
        vm.stopPrank();
    }

	function test_cantCreateAChat_userIsAlreadyInAChat() public {
		vm.startPrank(david);
		messBlock.createChat(bob); 
		vm.expectRevert(abi.encodeWithSelector(MessBlockChats.UserIsAlreadyInAChat.selector, bob));
		messBlock.createChat(bob); 
		vm.stopPrank();
	}

    function test_cantCreateChat_CantCreateAChatWithHimself() public {
        vm.startPrank(david);
        vm.expectRevert(MessBlockChats.CantCreateAChatWithSelf.selector);
        messBlock.createChat(david); 
        vm.stopPrank();
    }

    //sendMessage tests
    function test_canSendMessage() public {
        vm.startPrank(david);
        messBlock.createChat(bob); 
        messBlock.sendMessage(bob, "Hello Bob!"); 
        bytes memory chatHash = messBlock.getChatKey(david, bob);
        MessBlockChats.ChatMessage[] memory chat = messBlock.getChat(chatHash);
        assertEq(chat[0].from, david);
        assertEq(chat[0].message, "Hello Bob!");
        vm.stopPrank();

        vm.startPrank(bob);
        messBlock.sendMessage(david, "Hello David!"); 
        chatHash = messBlock.getChatKey(david, bob);
        chat = messBlock.getChat(chatHash);
        assertEq(chat[1].from, bob);
        assertEq(chat[1].message, "Hello David!");
        vm.stopPrank();
    }

    function test_cantSendMessage_UserIsNotInAChat() public {
        vm.startPrank(david);
        vm.expectRevert(abi.encodeWithSelector(MessBlockChats.UserIsNotInAChat.selector, bob));
        messBlock.sendMessage(bob, "Hello Bob!"); 
        vm.stopPrank();
    }
}
