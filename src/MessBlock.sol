//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7; 

import {MessBlockChats} from "./MessBlockChats.sol"; 
import {MessBlockGroups} from "./MessBlockGroups.sol";

/// @title MessBlock - A decentralized messaging and group chat contract
/// @notice This contract allows users to create chats, send/modify/delete messages, and manage groups.
/// @dev Provides both single chat and group chat functionality with access control and error handling.
contract MessBlock is MessBlockChats, MessBlockGroups {}