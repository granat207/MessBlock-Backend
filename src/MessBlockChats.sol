//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;  

contract MessBlockChats {

/// @notice Thrown when a user attempts to create a chat with someone already in their chat list.
error UserIsAlreadyInAChat(address user); 

/// @notice Thrown when a user attempts to create a chat with themselves.
error CantCreateAChatWithHimself();

/// @notice Thrown when a user attempts to delete a chat that does not exist.
error UserIsNotInAChat(address user); 

/// @notice Thrown when a user attempts to send a message to themselves.
error CantSendMessageToHimself();

struct ChatMessage {
address from; 
string message; 
uint256 timestamp;
}

mapping(address => mapping(address => bool)) internal isInAChat;
/// @notice Mapping of a user to their chats.
mapping(address => address[])internal addressToChats; 

mapping(bytes => ChatMessage[]) internal messages;	

mapping(address => mapping(address => bytes)) public chatKey; 


/// @notice Ensures a user is already in a chat before interacting.
/// @param user The address of the chat participant.
modifier userIsNotInAChat(address user){
if(isInAChat[msg.sender][user]){
	revert UserIsAlreadyInAChat(user); 
}
_;
}

modifier userIsInAChat(address user){
if(!isInAChat[msg.sender][user]){
	revert UserIsNotInAChat(user);	
}
_;
}


/// @notice Creates a new chat with another user.
/// @param newUser The address of the user to chat with.
function createChat(address newUser) public userIsNotInAChat(newUser){
if(newUser == msg.sender) {
	revert CantCreateAChatWithHimself();
}
addressToChats[msg.sender].push(newUser); 
addressToChats[newUser].push(msg.sender);
isInAChat[msg.sender][newUser] = true; 
isInAChat[newUser][msg.sender] = true; 

bytes memory chatKeyBytes = abi.encode(msg.sender, newUser);
chatKey[msg.sender][newUser] = chatKeyBytes;
chatKey[newUser][msg.sender] = chatKeyBytes;
}


/// @notice Sends a message to another user.
/// @param user The recipient of the message.
/// @param message The message content.
function sendMessage(address user, string memory message) public userIsInAChat(user){
ChatMessage memory newChatMessage = ChatMessage({
from: msg.sender,  
message: message, 
timestamp: block.timestamp
}); 
bytes memory _chatKey = chatKey[msg.sender][user];
messages[_chatKey].push(newChatMessage);
}


/// @notice Returns all chats of the sender.
/// @return Array of user addresses.
function returnUserChats() public view returns(address[] memory){
return addressToChats[msg.sender]; 
}


/// @notice Returns the chat between sender and another user.
/// @param _hash The bytes hash of the two user addresses.
/// @return Array of user messages.
function returnChat(bytes memory _hash) public view returns(ChatMessage[] memory){
return messages[_hash]; 
}

function returnChatKey(address userA, address userB) public view returns(bytes memory) {
	return chatKey[userA][userB];
}
}