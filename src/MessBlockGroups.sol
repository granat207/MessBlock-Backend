//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7; 

/// @title MessBlockGroups - Group messaging contract
/// @notice Allows users to create groups, join them, send group messages, and manage membership.
/// @dev Each group has a unique `id`. The creator is considered the "owner" and can manage its details.
contract MessBlockGroups {

    /// @notice Thrown when a user attempts to send a message in a group they are not part of.
    error CantSendMessageInTheGroup(address user, uint256 id); 

    /// @notice Thrown when a user who is not the owner attempts to manage the group.
    error SenderIsNotTheOwnerOfTheGroup();

    /// @notice Thrown when a user attempts to join a group they are already in.
    error UserCantJoinAGropWhenHeIsAlreadyIn(uint256 id); 

    /// @notice Thrown when a group does not exist.
    error GroupDoesNotExist(uint256 id);  

    /// @notice Emitted when a group is created.
    /// @param owner The address of the group creator.
    /// @param name The name of the group.
    /// @param description The description of the group.
    /// @param id The unique ID of the group.
    event GroupCreated(string name, string description, address owner, uint256 id); 

    /// @notice Emitted when a user joins a group.
    /// @param user The address of the user who joined.
    /// @param id The ID of the group joined.
    event UserJoinedGroup(address user, uint256 id); 

    /// @notice Emitted when a message is sent in a group.
    /// @param user The address of the sender.
    /// @param id The ID of the group.
    /// @param message The message content.
    /// @param timestamp The time the message was sent.
    event GroupMessageSent(address user, uint256 id, string message, uint256 timestamp);

    /// @notice Defines group details.
    struct Group {
        string name; 
        string description; 
        address owner; 
        uint256 id; 
    }

    /// @notice Defines messages within a group.
    struct GroupMessages {
        address sender; 
        string message; 
        uint256 timestamp;
    }

    /// @notice Counter tracking total number of groups created.
    uint256 public groupId;

    /// @notice List of all groups.
    Group[] public groups; 

    /// @notice Mapping of users to groups they joined.
    mapping(address => uint256[]) internal addressToGroupsJoined; 

    /// @notice Stores group metadata based on groupId.
    mapping(uint256 => Group) internal idToGroupData;

    /// @notice Stores group messages by groupId.
    mapping(uint256 => GroupMessages[]) internal idToGroupMessages; 

    /// @notice Tracks members of a group by groupId.
    mapping(uint256 => address[]) internal idToUsersWhoJoined; 

    /// @notice Tracks membership status for each user in a group.
    mapping(address => mapping(uint256 => bool)) internal isInGroup;

    /// @notice Ensures the group exists.
    /// @param id The group ID.
    modifier groupExists(uint256 id) {
        if(id >= groupId) {
            revert GroupDoesNotExist(id);
        }
        _; 
    }

    /// @notice Ensures the sender is not already in the group.
    /// @param id The group ID.
    modifier notAlreadyInTheGroup(uint256 id) {
        if(isInGroup[msg.sender][id]) {
            revert UserCantJoinAGropWhenHeIsAlreadyIn(id);
        }
        _;
    }

    /// @notice Ensures the sender is already in the group.
    /// @param id The group ID.
    modifier alreadyInTheGroup(uint256 id) {
        if(!isInGroup[msg.sender][id]) {
            revert CantSendMessageInTheGroup(msg.sender, id);
        }
        _;
    }

    /// @notice Creates a new group.
    /// @param name The group name.
    /// @param description The group description.
    function createGroup(string memory name, string memory description) external {
        Group memory newGroup = Group(name, description, msg.sender, groupId);
        groups.push(newGroup);
        idToGroupData[groupId] = newGroup;
        addressToGroupsJoined[msg.sender].push(groupId);
        idToUsersWhoJoined[groupId].push(msg.sender);
        isInGroup[msg.sender][groupId] = true;
        emit GroupCreated(name, description, msg.sender, groupId);
        groupId++;
    }

    /// @notice Allows a user to join an existing group.
    /// @param id The group ID.
    function joinGroup(uint256 id) external groupExists(id) notAlreadyInTheGroup(id) {
        addressToGroupsJoined[msg.sender].push(id);
        idToUsersWhoJoined[id].push(msg.sender);
        isInGroup[msg.sender][id] = true;
        emit UserJoinedGroup(msg.sender, id);
    }

    /// @notice Sends a message in a group.
    /// @param id The group ID.
    /// @param message The content of the message.
    function sendMessageInAGroup(uint256 id, string memory message) external alreadyInTheGroup(id) {
        GroupMessages memory newGroupMessage = GroupMessages({
            sender: msg.sender, 
            message: message,
            timestamp: block.timestamp
        }); 
        idToGroupMessages[id].push(newGroupMessage); 
        emit GroupMessageSent(msg.sender, id, message, block.timestamp); 
    }

    /// @notice Allows a user to leave a group.
    /// @param id The group ID.
    function leaveGroup(uint256 id) external alreadyInTheGroup(id){
        isInGroup[msg.sender][id] = false;
    }

    /// @notice Allows the group owner to change group metadata.
    /// @param id The group ID.
    /// @param newName New name for the group.
    /// @param newDescription New description for the group.
    function changeGroupNameAndDescription(uint256 id, string memory newName, string memory newDescription) external {
        if(groups[id].owner != msg.sender){
            revert SenderIsNotTheOwnerOfTheGroup();
        }
        groups[id].name = newName; 
        groups[id].description = newDescription;

        idToGroupData[id].name = newName;
        idToGroupData[id].description = newDescription;
    }

    /// @notice Returns the list of users who joined a group.
    /// @param id The group ID.
    /// @return Array of user addresses.
    function returnUsersWhoJoinedAgroup(uint256 id) external view returns(address[] memory){
        return idToUsersWhoJoined[id]; 
    }

    /// @notice Returns all existing groups.
    /// @return Array of groups.
    function returnGroups() external view returns(Group[] memory){
        return groups;
    }

    /// @notice Returns all groups joined by the sender.
    /// @return Array of group IDs.
    function returnJoinedGroups() external view returns(uint256[] memory){
        return addressToGroupsJoined[msg.sender];
    }

    /// @notice Returns all messages of a group.
    /// @param id The group ID.
    /// @return Array of group messages.
    function returnGroupMessages(uint256 id) external view returns(GroupMessages[] memory){
        return idToGroupMessages[id];
    }
}
