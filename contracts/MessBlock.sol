//SPDX-License-Identifier:MIT


pragma solidity ^0.8.7; 


contract MessBlock{


//*
//@dev returns the error if User try to create a chat with another User already in the chats.
//*
error UserAlreadyInAChat(); 


//*
//@dev returns the error if user try to delete a non existent chat.
//*
error UserIsNotInAChat(); 


//*
//@dev returns the error when a user try to create a Group with an already existent name
//*
error AlreadyExistAGroupWithThatName();


//*
//@dev returns the error when a user can't join in a group if he is already on that group
//*
error UserCantJoinAGropWhenHeIsAlreadyIn(); 

//*
//@dev returns the panic error in the function: sendGroupMessage
//*
error CantSendMessageInTheGroup(); 


//*
//@dev returns the panic error when a group is not deletable
//*
error GroupsNotDeletable(); 


//*
//@dev returns the panic error when user try to change the name or the description of the group
//*
error ErrorWhenChangingNameAndDescriptionGroup(); 


//*
//@dev returns the error when user try to modify the message in a group
//*
error ErrorWhenModifyMessageInGroups(string group_, string messageToModiy, string newMessage); 


//
//@dev returns the error when an user can't delete a chat
//
error UserCantDeleteTheChat(); 

//*
//@dev return the error when an user can't leave the group, maybe because he is not in the group
//*
error UserCantLeaveGroup(address sender, string name); 


//*
//@dev returns the event when a group is created
//*
event GroupCreated(address owner, string name); 


//*
//@dev returns the event when a group is deleted
//*
event GroupDeleted(address owner, string name); 


//*
//@dev return the event when a user join a group
//*
event UserJoinedGroup(address joiner, string name); 


//*
//@dev returns the struct to be a able to interact with the following functions: joinGroup, createGroup, leaveGroup..
//*
struct Group{
string name; 
string description; 
address groupOwner; 
}


//*
//@dev returns the struct to be able to interact with the following functions: sendMessageInAGroup, modifyGroupMessage, deleteGroupMessage
//*
struct GroupMessages{
string groupName; 
address sender; 
string messages; 
}


//*
//@dev returns the struct to be able to let user send, modify and delete their messagges. Everything seeing the message and the message sender(so the msg.sender when a transaction is done)
//*
struct UserMessagges{
string message; 
address messageSender; 
}


//*
//@dev set the the most important array about the groups to be able to create and delete them
//*
Group[] public groups; 


//User to all his chats, NOTE: this is internal and people can't see the chats of the others people, only msg.sender can views his chats.
mapping(address => address[])internal addressToChats; 


//The mapping below returns the strings(messages) behind msg.sender and another user, NOTE: This is internal and people can't see the messages of the others people, only msg.senders can views his messagges on the messblock website.
mapping(address => mapping(address => UserMessagges[]))internal addressToUserMessagess; 


//User to all the groups he joined
mapping(address => Group[])internal addressToGroupsJoined; 


//Name of the group to every message inside it
mapping(string => GroupMessages[])internal groupsToMessagesInside; 


//Name of the group to all the users of the group
mapping(string => address[])internal groupsToUsersIn; 


//With this modifier user can't open a new chat if the new user is already existent in his chats.
modifier isNotTheUserAlreadyInAChat(address newUser){
address[] memory usersChats = addressToChats[msg.sender]; 
for(uint256 i = 0; i < usersChats.length; i++){
if(newUser == usersChats[i]){
revert UserAlreadyInAChat(); 
}
}
_;
}


//With this modifier user can't delete a chat if the chat does not exist.
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


//SINGLE CHAT
//*
//@dev returns the function to create a chat.
//*
function createChat(address newUser)public isNotTheUserAlreadyInAChat(newUser){
require(newUser != msg.sender, "Can't create a chat with himself"); 
addressToChats[msg.sender].push(newUser); 
}


//*
//@dev sets the function to be able to deleteChats.
//*
function deleteChat(address deletedUser)public{ 
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


//*
//@dev sets the function to be able to send messages to other people, NOTE: if the user is not in a chat, sender can't send him message.
//*
function sendMessage(address user, string memory message) public isTheUserAlreadyInAChat(user){
require(user != msg.sender, "User cant be the sender"); 
UserMessagges memory newUserMessage = UserMessagges({
message: message, 
messageSender: msg.sender
}); 
addressToUserMessagess[msg.sender][user].push(newUserMessage); 
addressToChats[user].push(msg.sender); 
addressToUserMessagess[user][msg.sender].push(newUserMessage); 
}


//*
//With this function dev let user to modify their messagges with another user
//*
function modifyMessage(address user, string memory messageToModify, string memory newMessage)public{
bool txWentTrue = false; 
for(uint256 i = 0; i < addressToUserMessagess[msg.sender][user].length; i++){
if(keccak256(abi.encodePacked(addressToUserMessagess[msg.sender][user][i].message)) == keccak256(abi.encodePacked(messageToModify))){
addressToUserMessagess[msg.sender][user][i].message = newMessage; 
txWentTrue = true; 
}
}
if(txWentTrue == false){
revert("Cant modify the message"); 
}
}


//*
//With this function dev let user to delete their messagges in their single chat
//*
function deleteMessage(address user, string memory messageToDelete)public{
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
revert("Cant delete the message"); 
}
}


//GROUPS 
//*
//With this function is possible to create a group with a name and the description
//*
function createGroup(string memory name, string memory description)public{
for(uint256 a = 0; a < groups.length; a++){
if(keccak256(abi.encodePacked(groups[a].name)) == keccak256(abi.encodePacked(name))){
revert AlreadyExistAGroupWithThatName(); 
}
}
Group memory newGroup = Group({
name: name, 
description: description, 
groupOwner: msg.sender
}); 
groups.push(newGroup); 
addressToGroupsJoined[msg.sender].push(newGroup);  
groupsToUsersIn[name].push(msg.sender);
emit GroupCreated(msg.sender, name);
}


//*
//With this function owner of the group(onlyOnwer) can change the name and the description wanever he wants
//*
function changeGroupNameAndDescription(string memory oldName, string memory _newName, string memory _newDescription)public{
bool success = false; 
for(uint256 i = 0; i < groups.length; i++){
for(uint256 a = 0; a < addressToGroupsJoined[msg.sender].length; a++){
require(keccak256(abi.encodePacked(groups[i].groupOwner)) == keccak256(abi.encodePacked(msg.sender)), "Sender is not the owner of the group"); 
if(keccak256(abi.encodePacked(groups[i].name)) == keccak256(abi.encodePacked(oldName))){
Group memory groupWithNewDescriptionAndName = Group({
name: _newName, 
description: _newDescription,
groupOwner: msg.sender
}); 
groups[i] = groupWithNewDescriptionAndName; 
addressToGroupsJoined[msg.sender][a] = groupWithNewDescriptionAndName; 
delete groupsToUsersIn[oldName]; 
groupsToUsersIn[_newName].push(msg.sender); 
success = true; 
}
}
}
if(success == false){
revert("Error when changing the groupName and groupDescription"); 
}
}


//*
//With this function the owner of the group can delete the group
//*
function deleteGroup(string memory groupToDelete)public{
for (uint256 a = 0; a < groups.length; a++) {
require(keccak256(abi.encodePacked(groups[a].groupOwner)) == keccak256(abi.encodePacked(msg.sender)), "Sender is not the creator of the group"); 
if (keccak256(abi.encodePacked(groups[a].name)) == keccak256(abi.encodePacked(groupToDelete))){
leaveGroup(groupToDelete);
delete groups[a];
groups[a] = groups[groups.length - 1];
groups.pop();
delete groupsToUsersIn[groupToDelete]; 
return; 
}
}
revert GroupsNotDeletable();
}


//*
//With this function a user can join another group, if he is not already in
//*
function joinGroup(string memory name, string memory description)public{
bool groupExists = false;
Group memory groupToJoin; 
for (uint256 i = 0; i < groups.length; i++) {
if (keccak256(abi.encodePacked(groups[i].name)) == keccak256(abi.encodePacked(name)) &&
keccak256(abi.encodePacked(groups[i].description)) == keccak256(abi.encodePacked(description))) {
groupToJoin = Group({
name: name,
description: description,
groupOwner: groups[i].groupOwner
});
groupExists = true;
break;
}
}
Group[] memory userGroups = addressToGroupsJoined[msg.sender]; 
for(uint256 a = 0; a < userGroups.length; a++){
if(keccak256(abi.encodePacked(userGroups[a].name)) == keccak256(abi.encodePacked(name)) &&
keccak256(abi.encodePacked(userGroups[a].description)) == keccak256(abi.encodePacked(description))){
revert UserCantJoinAGropWhenHeIsAlreadyIn(); 
}
{
}
}
require(groupExists, "Group does not exist");
addressToGroupsJoined[msg.sender].push(groupToJoin);
groupsToUsersIn[name].push(msg.sender); 
emit UserJoinedGroup(msg.sender, name); 
}



//*
//With this function a user can leave the group if he is in the group
//*
function leaveGroup(string memory name)public{
removeUserFromTheGroupList(name);
for(uint256 i = 0; i < addressToGroupsJoined[msg.sender].length; i++){
if(keccak256(abi.encodePacked(addressToGroupsJoined[msg.sender][i].name)) == keccak256(abi.encodePacked(name))){
delete addressToGroupsJoined[msg.sender][i]; 
if(i < addressToGroupsJoined[msg.sender].length - 1){
uint256 lastIndex = addressToGroupsJoined[msg.sender].length - 1;
addressToGroupsJoined[msg.sender][i] = addressToGroupsJoined[msg.sender][lastIndex]; 
}
addressToGroupsJoined[msg.sender].pop(); 
return; 
}
}
revert UserCantLeaveGroup(msg.sender, name); 
}


//*
//This is an internal function used in leaveGroup function.
//*
function removeUserFromTheGroupList(string memory name)internal{
for(uint256 a = 0; a < groupsToUsersIn[name].length; a++){
if(keccak256(abi.encodePacked(groupsToUsersIn[name][a])) == keccak256(abi.encodePacked(msg.sender))){
delete groupsToUsersIn[name][a]; 
if(a < groupsToUsersIn[name].length  - 1){
uint256 _lastIndex = groupsToUsersIn[name].length - 1; 
groupsToUsersIn[name][a] = groupsToUsersIn[name][_lastIndex]; 
}
groupsToUsersIn[name].pop(); 
return;
}
}
}


//*
//With this function user can send a message in a group
//*
function sendMessagesInAGroup(string memory groupToSendMessagges, string memory _newMessage) public {
bool groupExists = false;
for (uint256 i = 0; i < addressToGroupsJoined[msg.sender].length; i++) {
if (keccak256(abi.encodePacked(addressToGroupsJoined[msg.sender][i].name)) == keccak256(abi.encodePacked(groupToSendMessagges))) {
GroupMessages memory newMessageInsideTheGroup = GroupMessages({
groupName: groupToSendMessagges,
sender: msg.sender,
messages: _newMessage
});
groupsToMessagesInside[groupToSendMessagges].push(newMessageInsideTheGroup);
groupExists = true;
break;
}
}
if (!groupExists) {
revert CantSendMessageInTheGroup();
}
}

//*
//With this function a user can modify the message in a group
//*
function modifyMessageInTheGroup(string memory groupToModifyMessage, string memory messageToBeModified,string memory _newMessage)public{
bool success = false; 
for(uint256 i = 0; i < groupsToMessagesInside[groupToModifyMessage].length; i++){
if(keccak256(abi.encodePacked(groupsToMessagesInside[groupToModifyMessage][i].messages)) == keccak256(abi.encodePacked(messageToBeModified))){
groupsToMessagesInside[groupToModifyMessage][i].messages= _newMessage; 
success = true; 
break; 
}
}
if(success == false){
revert("Cant modify the message in the group"); 
}
}


//*
//With this function a user can delete a message in the group
//*
function deleteMessageInTheGroup(string memory groupToDeleteMessage, string memory messageToBeDeleted)public{
bool success = false; 
for(uint256 i = 0; i < groupsToMessagesInside[groupToDeleteMessage].length; i++){
if(keccak256(abi.encodePacked(groupsToMessagesInside[groupToDeleteMessage][i].messages)) == keccak256(abi.encodePacked(messageToBeDeleted))){
require(keccak256(abi.encodePacked(groupsToMessagesInside[groupToDeleteMessage][i].sender)) == keccak256(abi.encodePacked(msg.sender))); 
delete groupsToMessagesInside[groupToDeleteMessage][i]; 
if(i < groupsToMessagesInside[groupToDeleteMessage].length - 1){
uint256 lastIndex = groupsToMessagesInside[groupToDeleteMessage].length - 1; 
groupsToMessagesInside[groupToDeleteMessage][i] = groupsToMessagesInside[groupToDeleteMessage][lastIndex]; 
}
groupsToMessagesInside[groupToDeleteMessage].pop(); 
success = true; 
return; 
}
}
if(success == false){
revert("Cant delete the message"); 
}
}


//*
//This function returns all the user chats
//*
function returnUserChats()public view returns(address[] memory){
return addressToChats[msg.sender]; 
}


//*
//@dev sets the function to let user see his chat with another user (This is higly recommended to be view and called via frontend with MessBlock website).
//*
function returnChat(address user)public isTheUserAlreadyInAChat(user) view returns(UserMessagges[] memory){
require(user != msg.sender, "Can't send messages to himself"); 
return addressToUserMessagess[msg.sender][user]; 
}


//*
//This function returns all the user existent in group
//*
function returnUsersInAGroup(string memory _group)public view returns(address[] memory){
return groupsToUsersIn[_group]; 
}

//*
//This function returns all the groups existent at the moment
//*
function returnAllTheGroups()public view returns(Group[] memory){
return groups; 
}


//*
//This function returns all the group when a user is in at the moment
//*
function returnUserGroups()public view returns(Group[] memory){
return addressToGroupsJoined[msg.sender]; 
}

//*
//This function returns all the messages in a group
//*
function returnGroupMessagges(string memory groupToSendMessagges)public view returns(GroupMessages[] memory){
return groupsToMessagesInside[groupToSendMessagges]; 
}
}