//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7; 

import {MessBlockChats} from "./MessBlockChats.sol"; 
import {MessBlockGroups} from "./MessBlockGroups.sol";

/// @title MessBlock - A decentralized messaging and group chat contract
/// @notice This contract combines both private chats and group chats into one system.
/// @dev Inherits from {MessBlockChats} for 1-to-1 chats and {MessBlockGroups} for group chat functionality.
///      Provides a unified interface for messaging with error handling, access control, and storage mappings.
contract MessBlock is MessBlockChats, MessBlockGroups {}