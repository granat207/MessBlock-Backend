//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7; 

contract MessBlockGroups {

/// @notice Thrown when a user attempts to create a group with an already existing name.
error AlreadyExistAGroupWithThatName();

/// @notice Thrown when a user attempts to send a message in a group they are not part of.
error CantSendMessageInTheGroup(); 

/// @notice Thrown when a user attempts to modify a message in a group but fails.
error CantModifyTheMessageInTheGroup();
 
/// @notice Thrown when a user attempts to delete a message in a group but fails.
error CantDeleteTheMessageInTheGroup(); 

/// @notice Thrown when a user who is not the owner attempts to manage the group.
error SenderIsNotTheOwnerOfTheGroup();

/// @notice Thrown when a user attempts to join a group they are already in.
error UserCantJoinAGropWhenHeIsAlreadyIn(); 

/// @notice Thrown when a group cannot be deleted.
error GroupsNotDeletable(); 

/// @notice Thrown when a group does not exist.
error GroupsDoesNotExist();

/// @notice Thrown when there is an error changing the name or description of a group.
error ErrorWhenChangingNameAndDescriptionGroup();  

/// @notice Thrown when a user cannot leave a group.
/// @param sender The address of the user.
/// @param name The name of the group.
error UserCantLeaveGroup(address sender, string name); 

/// @notice Emitted when a group is created.
/// @param owner The address of the group creator.
/// @param name The name of the group.
event GroupCreated(address owner, string name); 

/// @notice Emitted when a group is deleted.
/// @param owner The address of the group owner.
/// @param name The name of the deleted group.
event GroupDeleted(address owner, string name); 

/// @notice Emitted when a user joins a group.
/// @param joiner The address of the joining user.
/// @param name The name of the group.
event UserJoinedGroup(address joiner, string name); 

/// @notice Defines group details.
struct Group{
string name; 
string description; 
address groupOwner; 
}

/// @notice Defines messages within a group.
struct GroupMessages{
string groupName; 
address sender; 
string messages; 
}

/// @notice List of all groups.
Group[] public groups; 

/// @notice Mapping of users to groups they joined.
mapping(address => Group[])internal addressToGroupsJoined; 


/// @notice Mapping of group names to their messages.
mapping(string => GroupMessages[])internal groupsToMessagesInside; 


/// @notice Mapping of group names to their users.
mapping(string => address[])internal groupsToUsersIn; 

/// @notice Creates a new group.
/// @param name The group name.
/// @param description The group description.
function createGroup(string memory name, string memory description) public {
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


/// @notice Changes the name and description of a group.
/// @param oldName The current group name.
/// @param _newName The new group name.
/// @param _newDescription The new description.
function changeGroupNameAndDescription(string memory oldName, string memory _newName, string memory _newDescription) public {
bool success = false; 
for(uint256 i = 0; i < groups.length; i++){
	for(uint256 a = 0; a < addressToGroupsJoined[msg.sender].length; a++){		
		if(keccak256(abi.encodePacked(groups[i].groupOwner)) != keccak256(abi.encodePacked(msg.sender))){
			revert SenderIsNotTheOwnerOfTheGroup();
		}
		
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
	revert ErrorWhenChangingNameAndDescriptionGroup(); 
}
}


/// @notice Deletes a group owned by the sender.
/// @param groupToDelete The group name.
function deleteGroup(string memory groupToDelete) public {
for (uint256 a = 0; a < groups.length; a++) {
	if(keccak256(abi.encodePacked(groups[a].groupOwner)) != keccak256(abi.encodePacked(msg.sender))){
		revert SenderIsNotTheOwnerOfTheGroup();
	}
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


/// @notice Allows a user to join a group.
/// @param name The group name.
/// @param description The group description.
function joinGroup(string memory name, string memory description) public {
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

if(!groupExists){
	revert GroupsDoesNotExist(); 
}
addressToGroupsJoined[msg.sender].push(groupToJoin);
groupsToUsersIn[name].push(msg.sender); 
emit UserJoinedGroup(msg.sender, name); 
}



/// @notice Allows a user to leave a group.
/// @param name The group name.
function leaveGroup(string memory name) public {
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


/// @notice Internal function to remove a user from a group list.
/// @param name The group name.
function removeUserFromTheGroupList(string memory name) internal {
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


/// @notice Sends a message in a group.
/// @param groupToSendMessagges The group name.
/// @param _newMessage The message content.
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


/// @notice Modifies a message in a group.
/// @param groupToModifyMessage The group name.
/// @param messageToBeModified The original message.
/// @param _newMessage The new message content.
function modifyMessageInTheGroup(string memory groupToModifyMessage, string memory messageToBeModified,string memory _newMessage) public {
bool success = false; 
for(uint256 i = 0; i < groupsToMessagesInside[groupToModifyMessage].length; i++){
	if(keccak256(abi.encodePacked(groupsToMessagesInside[groupToModifyMessage][i].messages)) == keccak256(abi.encodePacked(messageToBeModified))){
		groupsToMessagesInside[groupToModifyMessage][i].messages= _newMessage; 
		success = true; 
		break; 
	}
}

if(success == false){
	revert CantModifyTheMessageInTheGroup(); 
}
}


/// @notice Deletes a message in a group.
/// @param groupToDeleteMessage The group name.
/// @param messageToBeDeleted The message to delete.
function deleteMessageInTheGroup(string memory groupToDeleteMessage, string memory messageToBeDeleted) public {
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
	revert CantDeleteTheMessageInTheGroup(); 
}
}


/// @notice Returns all users in a group.
/// @param _group The group name.
/// @return Array of user addresses.
function returnUsersInAGroup(string memory _group) public view returns(address[] memory){
return groupsToUsersIn[_group]; 
}


/// @notice Returns all existing groups.
/// @return Array of groups.
function returnAllTheGroups() public view returns(Group[] memory){
return groups; 
}


/// @notice Returns all groups joined by the sender.
/// @return Array of groups.
function returnUserGroups() public view returns(Group[] memory){
return addressToGroupsJoined[msg.sender]; 
}


/// @notice Returns all messages inside a group.
/// @param groupToSendMessagges The group name.
/// @return Array of group messages.
function returnGroupMessagges(string memory groupToSendMessagges) public view returns(GroupMessages[] memory){
return groupsToMessagesInside[groupToSendMessagges]; 
}
}