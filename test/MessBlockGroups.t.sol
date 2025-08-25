// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MessBlock} from "../src/MessBlock.sol";
import {MessBlockGroups} from "../src/MessBlockGroups.sol";

contract MessBlockGroupsTest is Test {

    address public david = makeAddr("david"); 
    address public bob = makeAddr("bob"); 
    MessBlock public messBlock;

    function setUp() public {
        messBlock = new MessBlock(); 
    }

    //createGroup tests
    function test_canCreateGroup() public {
        vm.prank(david); 
        messBlock.createGroup("group1", "description1"); 

        (string memory name, string memory description, address owner, uint256 id) = messBlock.groups(0); 

        assertEq(name, "group1"); 
        assertEq(description, "description1"); 
        assertEq(owner, david); 
        assertEq(id, 0); 
    }

    function test_canCreateMultiplesGroup() public {
        vm.prank(david); 
        vm.expectEmit(true, true, true, false); 
        emit MessBlockGroups.GroupCreated("group1", "description1", david, 0);
        messBlock.createGroup("group1", "description1"); 

        (string memory name, string memory description, address owner, uint256 id) = messBlock.groups(0); 

        assertEq(name, "group1"); 
        assertEq(description, "description1"); 
        assertEq(owner, david); 
        assertEq(id, 0); 

        vm.prank(bob); 
        vm.expectEmit(true, true, true, false); 
        emit MessBlockGroups.GroupCreated("group2", "description2", bob, 1);
        messBlock.createGroup("group2", "description2");    

        (string memory name2, string memory description2, address owner2, uint256 id2) = messBlock.groups(1); 

        assertEq(name2, "group2"); 
        assertEq(description2, "description2"); 
        assertEq(owner2, bob); 
        assertEq(id2, 1);


        assertEq(messBlock.groupId(), 2);

        assertEq(messBlock.getGroups().length, 2);
        assertEq(messBlock.getUsersWhoJoinedAgroup(0).length, 1);
  
    }

    function test_cantCreateGroupWithEmptyName() public {
        vm.prank(david); 
        vm.expectRevert(bytes("Group name can't be empty")); 
        messBlock.createGroup("", "description1"); 
    }

    //joinGroup tests
    function test_canJoinGroup() public {
        vm.startPrank(david); 
        messBlock.createGroup("group1", "description1");   
        vm.stopPrank();  
        vm.startPrank(bob); 
        vm.expectEmit(true, true, true, false); 
        emit MessBlockGroups.UserJoinedGroup(bob, 0);
        messBlock.joinGroup(0); 
        uint256[] memory groupsJoined = messBlock.getJoinedGroups(); 
        assertEq(groupsJoined.length, 1);
        assertEq(groupsJoined[0], 0);
    }

    function test_cantJoinNonExistentGroup() public {
        vm.startPrank(bob); 
        vm.expectRevert(abi.encodeWithSelector(MessBlockGroups.GroupDoesNotExist.selector, 0)); 
        messBlock.joinGroup(0); 
    }

    function test_cantJoinGroupWhenAlreadyIn() public {
        vm.startPrank(david); 
        messBlock.createGroup("group1", "description1");   
        vm.stopPrank();  
        vm.startPrank(bob); 
        messBlock.joinGroup(0); 
        vm.expectRevert(abi.encodeWithSelector(MessBlockGroups.UserIsAlreadyInAGroup.selector, 0)); 
        messBlock.joinGroup(0); 
    }

    //sendMessageInGroup tests
    function test_canSendMessageInGroup() public {
        vm.startPrank(david); 
        messBlock.createGroup("group1", "description1");   
        vm.stopPrank();  
        vm.startPrank(bob); 
        messBlock.joinGroup(0); 
        vm.expectEmit(true, true, true, false); 
        emit MessBlockGroups.GroupMessageSent(bob, 0, "Hello everyone!", block.timestamp);
        messBlock.sendMessageInAGroup(0, "Hello everyone!"); 
        MessBlockGroups.GroupMessages[] memory messages = messBlock.getGroupMessages(0); 
        assertEq(messages.length, 1);
        assertEq(messages[0].sender, bob);
        assertEq(messages[0].message, "Hello everyone!");
        vm.stopPrank();
    }

    function test_canSendMultipleMessagesInGroup() public {
        vm.startPrank(david); 
        messBlock.createGroup("group1", "description1");   
        vm.stopPrank();  
        vm.startPrank(bob); 
        messBlock.joinGroup(0); 
        vm.expectEmit(true, true, true, false);
        emit MessBlockGroups.GroupMessageSent(bob, 0, "Hello everyone!", block.timestamp);
        messBlock.sendMessageInAGroup(0, "Hello everyone!"); 
        vm.stopPrank();

        vm.startPrank(david); 
        vm.expectEmit(true, true, true, false);
        emit MessBlockGroups.GroupMessageSent(david, 0, "Hello Bob!", block.timestamp);
        messBlock.sendMessageInAGroup(0, "Hello Bob!"); 
        MessBlockGroups.GroupMessages[] memory messages = messBlock.getGroupMessages(0); 
        assertEq(messages.length, 2);
        assertEq(messages[0].sender, bob);
        assertEq(messages[0].message, "Hello everyone!");
        assertEq(messages[1].sender, david);
        assertEq(messages[1].message, "Hello Bob!");

        assertEq(messages[0].timestamp, block.timestamp); 
        assertEq(messages[1].timestamp, block.timestamp);
        vm.stopPrank();
    }

    function test_cantSendMessageInGroupWhenNotIn() public {
        vm.startPrank(david); 
        messBlock.createGroup("group1", "description1");   
        vm.stopPrank();  
        vm.startPrank(bob); 
        vm.expectRevert(abi.encodeWithSelector(MessBlockGroups.UserIsNotInAGroup.selector, bob, 0)); 
        messBlock.sendMessageInAGroup(0, "Hello everyone!"); 
    }

    //leaveGroup tests
    function test_canLeaveGroup() public {
        vm.startPrank(david); 
        messBlock.createGroup("group1", "description1");   
        vm.stopPrank();  

        vm.startPrank(bob); 
        messBlock.joinGroup(0); 
        assertEq(messBlock.isInGroup(bob, 0), true);
        vm.expectEmit(true, true, true, false); 
        emit MessBlockGroups.UserLeftGroup(bob, 0);
        messBlock.leaveGroup(0); 
        uint256[] memory groupsJoined = messBlock.getJoinedGroups(); 
        assertEq(groupsJoined.length, 1);
        assertEq(groupsJoined[0], 0);
        assertEq(messBlock.isInGroup(bob, 0), false);
    }

    function test_cantLeaveGroupWhenNotIn() public {
        vm.startPrank(david); 
        messBlock.createGroup("group1", "description1");   
        vm.stopPrank();  

        vm.startPrank(bob); 
        vm.expectRevert(abi.encodeWithSelector(MessBlockGroups.UserIsNotInAGroup.selector, bob, 0)); 
        messBlock.leaveGroup(0); 
    }

    //changeGroupNameAndDescription tests
    function test_canChangeGroupNameAndDescription() public {
        vm.startPrank(david); 
        messBlock.createGroup("group1", "description1");   
        messBlock.changeGroupNameAndDescription(0, "newGroupName", "newDescription"); 
        (string memory name, string memory description, , ) = messBlock.groups(0); 
        assertEq(name, "newGroupName");
        assertEq(description, "newDescription");    
        vm.stopPrank();
    }

    function test_cantChangeGroupNameAndDescriptionWhenNotOwner() public {
        vm.startPrank(david); 
        messBlock.createGroup("group1", "description1");   
        vm.stopPrank();  
        vm.startPrank(bob); 
        vm.expectRevert(abi.encodeWithSelector(MessBlockGroups.SenderIsNotTheOwnerOfTheGroup.selector, bob, 0)); 
        messBlock.changeGroupNameAndDescription(0, "newGroupName", "newDescription"); 
    }

  }