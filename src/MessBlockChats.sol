//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;  

/// @title MessBlockChats - Peer-to-peer messaging contract
/// @notice Handles direct (1-to-1) chats between users, message sending, and chat history retrieval.
/// @dev Relies on bidirectional mappings between addresses to establish chats.
///      Each chat is identified by a unique `chatKey` generated from the two addresses.
contract MessBlockChats {

    /// @notice Thrown when a user attempts to create a chat with someone already in their chat list.
    error UserIsAlreadyInAChat(address user); 

    /// @notice Thrown when a user attempts to create a chat with themselves.
    error CantCreateAChatWithSelf();

    /// @notice Thrown when a user attempts to delete or interact with a chat that does not exist.
    error UserIsNotInAChat(address user); 

    /// @notice Defines a chat message between two users.
    /// @param from The address of the message sender.
    /// @param message The textual content of the message.
    /// @param timestamp The time (in seconds since Unix epoch) when the message was sent.
    struct ChatMessage {
        address from; 
        string message; 
        uint256 timestamp;
    }

    /// @notice Internal mapping to track whether two users are in a chat.
    mapping(address => mapping(address => bool)) internal isInAChat;

    /// @notice Mapping from user to their list of active chats.
    mapping(address => address[]) internal addressToChats; 

    /// @notice Stores messages based on chatKey (encoded pair of user addresses).
    mapping(bytes => ChatMessage[]) internal messages;	

    /// @notice Maps two users to a unique chatKey.
    mapping(address => mapping(address => bytes)) public chatKey; 

    /// @notice Ensures that a user is not already in a chat before creating one.
    /// @param user The address of the target chat participant.
    modifier userIsNotInAChat(address user){
        if(isInAChat[msg.sender][user]){
            revert UserIsAlreadyInAChat(user); 
        }
        _;
    }

    /// @notice Ensures that a user is already in a chat before sending/reading messages.
    /// @param user The address of the target chat participant.
    modifier userIsInAChat(address user){
        if(!isInAChat[msg.sender][user]){
            revert UserIsNotInAChat(user);	
        }
        _;
    }

    /// @notice Creates a new chat with another user.
    /// @dev Generates a `chatKey` based on the encoded pair of addresses.
    /// @param newUser The address of the user to chat with.
    function createChat(address newUser) external userIsNotInAChat(newUser){
        if(newUser == msg.sender) {
            revert CantCreateAChatWithSelf();
        }

        addressToChats[msg.sender].push(newUser); 
        addressToChats[newUser].push(msg.sender);
        isInAChat[msg.sender][newUser] = true; 
        isInAChat[newUser][msg.sender] = true; 

        bytes memory chatKeyBytes = abi.encode(msg.sender, newUser);
        chatKey[msg.sender][newUser] = chatKeyBytes;
        chatKey[newUser][msg.sender] = chatKeyBytes;
    }

    /// @notice Sends a message to another user in an existing chat.
    /// @dev Stores the message in the `messages` mapping, keyed by chatKey.
    /// @param user The recipient of the message.
    /// @param message The message content.
    function sendMessage(address user, string memory message) external userIsInAChat(user){
        ChatMessage memory newChatMessage = ChatMessage({
            from: msg.sender,  
            message: message, 
            timestamp: block.timestamp
        }); 
        bytes memory _chatKey = chatKey[msg.sender][user];
        messages[_chatKey].push(newChatMessage);
    }

    /// @notice Returns all chats of the sender.
    /// @return Array of addresses representing chat partners.
    function getUserChats() external view returns(address[] memory){
        return addressToChats[msg.sender]; 
    }

    /// @notice Returns the chat history between sender and another user.
    /// @param hash The bytes chatKey of the two user addresses.
    /// @return Array of chat messages.
    function getChat(bytes memory hash) external view returns(ChatMessage[] memory){
        return messages[hash]; 
    }

    /// @notice Returns the unique chatKey for two users.
    /// @param userA First user address.
    /// @param userB Second user address.
    /// @return Encoded chatKey (bytes).
    function getChatKey(address userA, address userB) external view returns(bytes memory) {
        return chatKey[userA][userB];
    }
}