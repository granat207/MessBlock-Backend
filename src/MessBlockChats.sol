//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;  

contract MessBlockChats {

/// @notice Thrown when a user attempts to create a chat with someone already in their chat list.
error UserAlreadyInAChat(); 

/// @notice Thrown when a user attempts to delete a chat that does not exist.
error UserIsNotInAChat(); 

/// @notice Thrown when a user attempts to create a chat with themselves.
error CantCreateAChatWithHimself();

/// @notice Thrown when a user attempts to send a message to themselves.
error CantSendMessageToHimself();

/// @notice Thrown when a user attempts to modify a message in a single chat but fails.
error CantModifyTheMessage(); 

/// @notice Thrown when a user attempts to delete a message in a single chat but fails.
error CantDeleteTheMessage();

/// @notice Thrown when a user cannot delete a chat.
error UserCantDeleteTheChat();

/// @notice Defines messages within a user chat.
struct UserMessagges{
string message; 
address messageSender; 
}

/// @notice Mapping of a user to their chats.
mapping(address => address[])internal addressToChats; 

/// @notice Mapping of users to their messages with other users.
mapping(address => mapping(address => UserMessagges[]))internal addressToUserMessagess; 

/// @notice Ensures a user cannot create a chat with someone already in their chat list.
/// @param newUser The address of the new chat user.
modifier isNotTheUserAlreadyInAChat(address newUser) {
address[] memory usersChats = addressToChats[msg.sender]; 
for(uint256 i = 0; i < usersChats.length; i++){
	if(newUser == usersChats[i]){
		revert UserAlreadyInAChat(); 
	}
}
_;
}


/// @notice Ensures a user is already in a chat before interacting.
/// @param deletedUser The address of the chat participant.
modifier isTheUserAlreadyInAChat(address deletedUser){
bool isInAchat = false; 
for(uint256 i = 0; i < addressToChats[msg.sender].length; i++){
	if(addressToChats[msg.sender][i] == deletedUser){
		isInAchat = true; 
	}
}

if(isInAchat == false){
	revert UserIsNotInAChat(); 
}
_;
}


/// @notice Creates a new chat with another user.
/// @param newUser The address of the user to chat with.
function createChat(address newUser) public isNotTheUserAlreadyInAChat(newUser){
if(newUser == msg.sender) {
	revert CantCreateAChatWithHimself();
}
addressToChats[msg.sender].push(newUser); 
}


/// @notice Deletes a chat with another user.
/// @param deletedUser The address of the user to remove from chats.
function deleteChat(address deletedUser) public { 
bool txWentTrue = false; 
for(uint256 i = 0; i < addressToChats[msg.sender].length; i++){
	if(keccak256(abi.encodePacked(addressToChats[msg.sender][i])) == keccak256(abi.encodePacked(deletedUser))){
		uint256 getLastElement = addressToChats[msg.sender].length - 1; 
		addressToChats[msg.sender][i] = addressToChats[msg.sender][getLastElement]; 
		txWentTrue = true; 
	} 

addressToChats[msg.sender].pop(); 
}

if(!txWentTrue){
	revert UserCantDeleteTheChat(); 
}
}


/// @notice Sends a message to another user.
/// @param user The recipient of the message.
/// @param message The message content.
function sendMessage(address user, string memory message) public isTheUserAlreadyInAChat(user){
if(user == msg.sender) {
	revert CantSendMessageToHimself();
}  
UserMessagges memory newUserMessage = UserMessagges({
message: message, 
messageSender: msg.sender
}); 
addressToUserMessagess[msg.sender][user].push(newUserMessage); 
addressToChats[user].push(msg.sender); 
addressToUserMessagess[user][msg.sender].push(newUserMessage); 
}


/// @notice Modifies an existing message in a chat.
/// @param user The chat participant.
/// @param messageToModify The original message.
/// @param newMessage The new message content.
function modifyMessage(address user, string memory messageToModify, string memory newMessage) public {
bool txWentTrue = false; 
for(uint256 i = 0; i < addressToUserMessagess[msg.sender][user].length; i++){
	if(keccak256(abi.encodePacked(addressToUserMessagess[msg.sender][user][i].message)) == keccak256(abi.encodePacked(messageToModify))){
		addressToUserMessagess[msg.sender][user][i].message = newMessage; 
		txWentTrue = true; 
	}
}

if(txWentTrue == false){
	revert CantModifyTheMessage(); 
}
}


/// @notice Deletes a message in a chat.
/// @param user The chat participant.
/// @param messageToDelete The message to delete.
function deleteMessage(address user, string memory messageToDelete) public {
bool txWentTrue = false; 
for(uint256 i = 0; i < addressToUserMessagess[msg.sender][user].length; i++){
	if(keccak256(abi.encodePacked(addressToUserMessagess[msg.sender][user][i].message)) == keccak256(abi.encodePacked(messageToDelete))){
		uint256 lastIndex = addressToUserMessagess[msg.sender][user].length - 1; 
		addressToUserMessagess[msg.sender][user][i] = addressToUserMessagess[msg.sender][user][lastIndex]; 
		txWentTrue = true; 
	}

addressToUserMessagess[msg.sender][user].pop(); 
}
if(txWentTrue == false){
	revert CantDeleteTheMessage(); 
}
}


/// @notice Returns all chats of the sender.
/// @return Array of user addresses.
function returnUserChats() public view returns(address[] memory){
return addressToChats[msg.sender]; 
}


/// @notice Returns the chat between sender and another user.
/// @param user The chat participant.
/// @return Array of user messages.
function returnChat(address user) public isTheUserAlreadyInAChat(user) view returns(UserMessagges[] memory){
if(user == msg.sender) {
	revert CantSendMessageToHimself();
} 
return addressToUserMessagess[msg.sender][user]; 
}
}