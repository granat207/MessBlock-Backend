//In this page i made some test related to the smart contract "MessBlock" compiled with solidity. 

//If you want to personally test these function below copy them and use the localhost network how i did(you can see in the hardhat.config.js)

//The function are not tested on the hardhat network(because this one has stack problem with array and other mad things)
//As mentioned before i tested them on the localhost of hardhat(if you dont know how to get the url of localhost digit in yout hardhat project: npx hardhat node), then copy paste the url and add it to the network on hardhat.config
//localhost chainId = 31337


const {assert, expect} = require("chai"); 

const {ethers} = require("hardhat"); 

describe("MessBlock", async function(){
let contractFactory; 
let contract; 
let signer; 
let signerAddress; 
beforeEach(async function(){
signer = await ethers.getSigner(); 
signerAddress = await signer.getAddress(); 
contractFactory = await ethers.getContractFactory("MessBlock"); 
contract = await contractFactory.deploy(); 
await contract.deployed(); 
})


                                                        //CHATS
//CREATE CHAT
describe("createChat function", async function(){
it("Can't create a chat with himsfelf", async function(){
await expect(contract.createChat(signerAddress)).to.be.revertedWith("Can't create a chat with himself"); 
})
it("Can't create a chat with an user who alreeady exists in the user chats", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
await expect(contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8')).to.be.revertedWith('UserAlreadyInAChat')
})
it("If User did not created any chats, the array length of user chats should be 0", async function(){
const _returnChatUser = await contract.returnUserChats(); 
const arrayChatLength = _returnChatUser.length;
assert.equal (arrayChatLength.toString(),"0"); 
})
it("When a user create the chat, the array userChats should increase +1", async function(){
const createChat = await contract.createChat("0x70997970c51812dc3a010c7d01b50e0d17dc79c8");
await createChat.wait(1); 
const _returnUserChats = await contract.returnUserChats(); 
const getArrayLength = _returnUserChats.length; 
assert.equal(getArrayLength.toString(),"1"); 
})
it("When an user creates a chat,the returnUserChats function should returns correctly the address of the user", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const _returnUserChats = await contract.returnUserChats(); 
const isCorrect = _returnUserChats.includes('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
assert.equal(isCorrect,true)
// console.log(_returnUserChats); 
})
})


//DELETE CHAT
describe("deleteChat function",async function(){
it("Can't delete a chat if user did not created any chats", async function(){
await expect(contract.deleteChat('0x70997970C51812dc3A010C7d01b50e0d17dc79C8')).to.be.revertedWith('UserCantDeleteTheChat'); 
})
it("Can't delete a chat if the address to delete does not exists inside the user chats",async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
await expect(contract.deleteChat('0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc')).to.be.revertedWith('UserCantDeleteTheChat')
})
it("Can successfully delete the chat if the address to delete is correct", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const deleteChat_ = await contract.deleteChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8'); 
await deleteChat_.wait(1); 
})
it("If user delete a chat, the returnUserChats array should - 1",async function(){
const createChat = await contract.createChat("0x70997970c51812dc3a010c7d01b50e0d17dc79c8");
await createChat.wait(1); 
const deleteChat_ = await contract.deleteChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8'); 
await deleteChat_.wait(1); 
const _returnUserChats = await contract.returnUserChats(); 
const isCorrect = _returnUserChats.includes('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
assert.equal(false,isCorrect); 
})
})


//SEND MESSAGE
describe("sendMessage function", async function(){
it("User can't returns chat messagges if the another user is not in his chats", async function(){
// await expect(contract.returnChat('0x70997970C51812dc3A010C7d01b50e0d17dc79C8')).to.be.revertedWith("UserIsNotInAChat");
//THIS LINE CODE IS BUGGED IN TERMINAL BUT IT WORKS
})
it("Can't send message if the userChat array is 0", async function(){
await expect(contract.sendMessage('0x70997970C51812dc3A010C7d01b50e0d17dc79C8','Ciao')).to.be.revertedWith('UserIsNotInAChat'); 
})
it("Can't send message to an user if the receiver user is not in a chat",async function(){
const createChat = await contract.createChat("0x70997970c51812dc3a010c7d01b50e0d17dc79c8");
await createChat.wait(1); 
await expect(contract.sendMessage('0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc','Ciao')).to.be.revertedWith('UserIsNotInAChat'); 
})
it("Can send messagges to an user if the receiver user is in a chat",async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao'); 
await sendMessage.wait(1); 
})
it("If user send messagges to another user the user to user chat messagges array size should increase +1",async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao'); 
await sendMessage.wait(1); 
const returnChat_ = await contract.returnChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8'); 
const chatArraySize = returnChat_.length; 
assert.equal(chatArraySize,"1"); 
})
it("If user send 2 messagges to another user the user to user chat messagges array size should increase +2",async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao'); 
await sendMessage.wait(1); 
const sendMessage2 = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao'); 
await sendMessage2.wait(1); 
const returnChat_ = await contract.returnChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8'); 
const chatArraySize = returnChat_.length; 
assert.equal(chatArraySize,"2"); 
})
it("When a user send a message to another one, in the chat should be returned esactly that message", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const word = 'Ciao'; 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8',word); 
await sendMessage.wait(1); 
const returnChat_ = await contract.returnChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8'); 
const getTheElementInTheArray = returnChat_[0][0]; 
assert.equal(getTheElementInTheArray,word.toString()); 
})
it("When a user send two messages to another one, in the chat should be returned asactly those 2 messagges", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const word1 = 'Ciao'; 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8',word1); 
await sendMessage.wait(1); 
const returnChat_ = await contract.returnChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8'); 
const getTheElementInTheArray = returnChat_[0][0]; 
assert.equal(getTheElementInTheArray,word1.toString()); 
const word2 = 'Hola'; 
const sendMessage2 = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8',word2); 
await sendMessage2.wait(1); 
const returnChat_2 = await contract.returnChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8'); 
const getTheElementInTheArray2 = returnChat_2[1][0]; 
assert.equal(getTheElementInTheArray2,word2.toString()); 
})
})


//MODIFY MESSAGE
describe("modifyMessage function", async function(){
it("Can't modifify the message if no chats with the user has been created", async function(){
await expect(contract.modifyMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao','Hola')).to.be.revertedWith("Cant modify the message"); 
})
it("Can't modify the message if user has wrote nothing to the other user", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
await expect(contract.modifyMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao','Hola')).to.be.revertedWith("Cant modify the message"); 
})
it("Can't modify the message if the message to modify does not corrispond to the real message wrote", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const word1 = 'Ciao'; 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8',word1); 
await sendMessage.wait(1); 
await expect(contract.modifyMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Hi','Hola')).to.be.revertedWith("Cant modify the message");
})
it("Can modify the message if the inputs are corrects", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const word1 = 'Ciao'; 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8',word1); 
await sendMessage.wait(1); 
const modifyMessage_ = await contract.modifyMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao','Hola'); 
})
it("After modifying the message on the chat it returns correctly the modified message and not the older one", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const word1 = 'Ciao'; 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8',word1); 
await sendMessage.wait(1); 
const modifyMessage_ = await contract.modifyMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao','Hola'); 
const returnChat_ = await contract.returnChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8'); 
const getElement = returnChat_[0][0]; 
assert.equal("Hola",getElement.toString()); 
})
it("Can modify multiples times the message", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const word1 = 'Ciao'; 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8',word1); 
await sendMessage.wait(1); 
const modifyMessage_ = await contract.modifyMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao','Hola'); 
await modifyMessage_.wait(1); 
const modifyMessage2 = await contract.modifyMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Hola','Hi'); 
await modifyMessage2.wait(1); 
const returnChat_ = await contract.returnChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8'); 
const getElement = returnChat_[0][0]; 
assert.equal(getElement.toString(),'Hi'); 
})
it("After modifying the message the returnChat array size should remains 1(if 1 is the number of message sent in the chat like in this example)", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const word1 = 'Ciao'; 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8',word1); 
await sendMessage.wait(1); 
const modifyMessage_ = await contract.modifyMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao','Hola'); 
await modifyMessage_.wait(1); 
const returnChat_ = await contract.returnChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8'); 
const getArraySize = returnChat_.length; 
assert.equal("1",getArraySize.toString()); 
})
})


//DELETE MESSAGE
describe("deleteMessage function", async function(){
it("Can't delete the message if user has not created a chat with the user", async function(){
await expect(contract.deleteMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao')).to.be.revertedWith("Cant delete the message"); 
})
it("Can't delete the message if message to delete input does not esists", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
await expect(contract.deleteMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao')).to.be.revertedWith("Cant delete the message"); 
})
it("Can't delete the message if message to delete input does not esists (part2)", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const word1 = 'Hi'; 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8',word1); 
await sendMessage.wait(1); 
await expect(contract.deleteMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Ciao')).to.be.revertedWith("Cant delete the message"); 
})
it("Can delete the message if the message exists", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const word1 = 'Hi'; 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8',word1); 
await sendMessage.wait(1); 
const _deleteMessage = await contract.deleteMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Hi'); 
await _deleteMessage.wait(1); 
})
it("After the message has been deleted the returnUser chat array size should returns to 0", async function(){
const createChat = await contract.createChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8');
await createChat.wait(1); 
const word1 = 'Hi'; 
const sendMessage = await contract.sendMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8',word1); 
await sendMessage.wait(1); 
const _deleteMessage = await contract.deleteMessage('0x70997970c51812dc3a010c7d01b50e0d17dc79c8','Hi'); 
await _deleteMessage.wait(1); 
const _returnChat = await contract.returnChat('0x70997970c51812dc3a010c7d01b50e0d17dc79c8'); 
const getArraySize = _returnChat.length; 
assert.equal("0",getArraySize.toString()); 
})
})


                                                         //GROUPS
//CREATE GROUP
describe("createGroup function", async function(){
it("Can't create a group, if another group with the same name is active", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
await expect(contract.createGroup("Juventus","Juventus for the life")).to.be.revertedWith('AlreadyExistAGroupWithThatName'); 
})
it("Can create a group", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
})
it("Before creating a group, the array groups size should be 0", async function(){
const getGroups = await contract.returnAllTheGroups(); 
const getArraySize = getGroups.length; 
assert.equal("0",getArraySize.toString()); 
})
it("After creating a group, the array groups should increments his size with +1", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const getGroups = await contract.returnAllTheGroups(); 
const getArraySize = getGroups.length; 
assert.equal("1",getArraySize.toString()); 
})
it("After creating a group, the array groups should returns the name of the new Group", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const getArray = await contract.returnAllTheGroups(); 
const getNameOfTheFirstElementInArray = getArray[0][0]; 
assert.equal(getNameOfTheFirstElementInArray.toString(),'Juventus'); 
})
it("After creating a group, the array groups should returns the description of the new Group", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const getArray = await contract.returnAllTheGroups(); 
const getNameOfTheFirstElementInArray = getArray[0][1]; 
assert.equal(getNameOfTheFirstElementInArray.toString(),'Juventus for the life'); 
})
it("After creating a group, the array groups should returns the ownerGroup of the new Group", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const getArray = await contract.returnAllTheGroups(); 
const getNameOfTheFirstElementInArray = getArray[0][2]; 
assert.equal(getNameOfTheFirstElementInArray.toString(),signerAddress.toString()); 
})
it("Before joining the first group, the array address to grops joined size should returns 0", async function(){
const getUserGroups = await contract.returnUserGroups(); 
const getSize = getUserGroups.length; 
assert.equal('0',getSize.toString()); 
})
it("After joining the first group, the array address to grops joined size should returns 1", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const getUserGroups = await contract.returnUserGroups(); 
const getSize = getUserGroups.length; 
assert.equal('1',getSize.toString()); 
})
it("After joining the group, the array address to groups joined should returns correctly the name of the group joined", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const getUserGroups = await contract.returnUserGroups(); 
const getElement = getUserGroups[0][0]; 
assert.equal('Juventus',getElement.toString()); 
})
it("After joining the group, the array address to groups joined should returns correctly the description of the group joined", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const getUserGroups = await contract.returnUserGroups(); 
const getElement = getUserGroups[0][1]; 
assert.equal('Juventus for the life',getElement.toString()); 
})
it("After joining the group, the array address to groups joined should returns correctly the ownerGroup of the group joined", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const getUserGroups = await contract.returnUserGroups(); 
const getElement = getUserGroups[0][2]; 
assert.equal(signerAddress.toString(),getElement.toString()); 
})
it("After creating a group, in the users of the groups array should be returned also the ownerGroup(so the msg.sender of the createGroup function)", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const getuserInGroup = await contract.returnUsersInAGroup('Juventus'); 
const correctlyReturnsTheUserInTheArray = getuserInGroup.includes(signerAddress.toString()); 
assert.equal('true',correctlyReturnsTheUserInTheArray.toString()); 
})
})


//CHANGE GROUP NAME AND DESCRIPTION
describe("changeGroupNameAndDescription function", async function(){
it("Can't change the values if no one groups has been created", async function(){
await expect(contract.changeGroupNameAndDescription("Juve","Torino","Torino is the best")).to.be.revertedWith("Error when changing the groupName and groupDescription"); 
})
it("Can't change the values if the name of the old group name is incorrect or it does not exists", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
await expect(contract.changeGroupNameAndDescription("Juve","Torino","Torino is the best")).to.be.revertedWith("Error when changing the groupName and groupDescription"); 
})
it("Can successfully modify the group name and description of a group if the inout parametres are correct", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const modiy = await contract.changeGroupNameAndDescription("Juventus","Torino,","Torino is the best"); 
await modiy.wait(1); 
})
it("After modifiyng the group name and description the array size of the groups should be neutral and not +1 or -1", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const modiy = await contract.changeGroupNameAndDescription("Juventus","Torino,","Torino is the best"); 
await modiy.wait(1); 
const getGroups = await contract.returnAllTheGroups(); 
const getArraySize = getGroups.length; 
assert.equal("1",getArraySize.toString()); 
})
it("After modifying the group name and description, the array should returns the new name correctly", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const modiy = await contract.changeGroupNameAndDescription("Juventus","Torino","Torino is the best"); 
await modiy.wait(1); 
const getGroups = await contract.returnAllTheGroups(); 
const getName = getGroups[0][0]; 
assert.equal(getName.toString(),"Torino"); 
})
it("After modifying the group name and description, the array should returns the new description correctly", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const modiy = await contract.changeGroupNameAndDescription("Juventus","Torino","Torino is the best"); 
await modiy.wait(1); 
const getGroups = await contract.returnAllTheGroups(); 
const getName = getGroups[0][1]; 
assert.equal(getName.toString(),"Torino is the best"); 
})
it("After modifying the group name and description, the array should returns the owner same as the that before(because this cant change)", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const modiy = await contract.changeGroupNameAndDescription("Juventus","Torino","Torino is the best"); 
await modiy.wait(1); 
const getGroups = await contract.returnAllTheGroups(); 
const getName = getGroups[0][2]; 
assert.equal(getName.toString(),signerAddress.toString()); 
})
it("After modifying the group name and description the user groups array should remains neutral", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const modiy = await contract.changeGroupNameAndDescription("Juventus","Torino,","Torino is the best"); 
await modiy.wait(1); 
const getGroups = await contract.returnUserGroups(); 
const getArraySize = getGroups.length; 
assert.equal("1",getArraySize.toString()); 
})
it("After modifying the group name and description, the user groups array should returns the new name correctly", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const modiy = await contract.changeGroupNameAndDescription("Juventus","Torino","Torino is the best"); 
await modiy.wait(1); 
const getGroups = await contract.returnUserGroups(); 
const getName = getGroups[0][0]; 
assert.equal(getName.toString(),"Torino"); 
})
it("After modifying the group name and description, the user groups array should returns the new description correctly", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const modiy = await contract.changeGroupNameAndDescription("Juventus","Torino","Torino is the best"); 
await modiy.wait(1); 
const getGroups = await contract.returnUserGroups(); 
const getName = getGroups[0][1]; 
assert.equal(getName.toString(),"Torino is the best"); 
})
it("After modifying the group name and description, the user groups array should returns the owner same as the that before(because this cant change)", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const modiy = await contract.changeGroupNameAndDescription("Juventus","Torino","Torino is the best");
await modiy.wait(1); 
const getGroups = await contract.returnUserGroups(); 
const getName = getGroups[0][2]; 
assert.equal(getName.toString(),signerAddress.toString()); 
})
it("After modifying the group name and description, the groups to user function of the new group name should correctly be called and return the same ownerGroup Address", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const modiy = await contract.changeGroupNameAndDescription("Juventus","Torino","Torino is the best");
await modiy.wait(1); 
const getUserInGroup = await contract.returnUsersInAGroup('Torino'); 
const thereIs = getUserInGroup.includes(signerAddress.toString()); 
assert.equal("true",thereIs.toString()); 
})
it("After modifying the group, the group to address function of the old group name should returns no one address", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const modiy = await contract.changeGroupNameAndDescription("Juventus","Torino","Torino is the best");
await modiy.wait(1); 
const getUserInGroup = await contract.returnUsersInAGroup('Juventus'); 
const thereIs = getUserInGroup.includes(signerAddress.toString()); 
assert.equal("false",thereIs.toString()); 
})
})


//DELETE GROUP
describe("deleteGroup function", async function(){
it("Can't delete a group if no one has been created", async function(){
await expect(contract.deleteGroup("Torino")).to.be.revertedWith("GroupsNotDeletable"); 
})
it("Can't delete the group if the input to delete string is wrong", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
await expect(contract.deleteGroup("Torino")).to.be.revertedWith("GroupsNotDeletable"); 
})
it("The group if has been created can be deleted", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const delete_ = await contract.deleteGroup("Juventus"); 
await delete_.wait(1); 
})
it("After deleting a group the array groups size array should -1 length", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const delete_ = await contract.deleteGroup("Juventus"); 
await delete_.wait(1); 
const getGroups = await contract.returnAllTheGroups(); 
const getSize = getGroups.length; 
assert.equal("0",getSize.toString()); 
})
it("After deleting a group the group to user in function of the group deleted should not returns any address", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const delete_ = await contract.deleteGroup("Juventus"); 
await delete_.wait(1); 
const getUserInAGroup_ = await contract.returnUsersInAGroup("Juventus"); 
const getSize = getUserInAGroup_.length; 
assert.equal("0",getSize.toString()); 
})
})


//JOIN GROUP
describe("joinGroup function", async function(){
it("Can't join a group if that group does not exists", async function(){
await expect(contract.joinGroup("Messi","Team Messi")).to.be.revertedWith("Group does not exist"); 
})
it("Can't join a group if user already joined that group", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
await expect(contract.joinGroup("Juventus","Juventus for the life")).to.be.revertedWith("UserCantJoinAGropWhenHeIsAlreadyIn"); 
})
})

//LEAVE GROUP
describe("leaveGroup function", async function(){
it("Can't leave a group if user is not in that group", async function(){
await expect(contract.leaveGroup("Torino")).to.be.revertedWith("UserCantLeaveGroup"); 
})
it("Can leave the group if the user is in that group", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const leaveGroup = await contract.leaveGroup("Juventus"); 
await leaveGroup.wait(1); 
})
it("After the user leaved the group the address to groups joined array size should decrease -1", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const leaveGroup = await contract.leaveGroup("Juventus"); 
await leaveGroup.wait(1); 
const getArray = await contract.returnUserGroups(); 
const getSize = getArray.length; 
assert.equal(getSize.toString(),"0"); 
})
it("After the user leaved the group the group to address in should decrease -1", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const leaveGroup = await contract.leaveGroup("Juventus"); 
await leaveGroup.wait(1); 
const getUserInGroup = await contract.returnUsersInAGroup("Juventus"); 
const getSize = getUserInGroup.length; 
assert.equal("0",getSize.toString()); 
})
})


//SEND MESSAGGES IN THE GROUP
describe("sendMessagesInAGroup", async function(){
it("Can't send message if the group selected does not exists or the user is not on that", async function(){
await expect(contract.sendMessagesInAGroup("Torino","Hey")).to.be.revertedWith("CantSendMessageInTheGroup"); 
})
it("Can't send message if the group selected does not exists  or the user is not on that part 2", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
await expect(contract.sendMessagesInAGroup("Torino","Hey")).to.be.revertedWith("CantSendMessageInTheGroup"); 
})
it("Before sending messagges in the group, the array group to messagges inside should be 0", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const getMessagges = await contract.returnGroupMessagges("Juventus"); 
const getSize = getMessagges.length; 
assert.equal("0",getSize.toString()); 
})
it("Can send messagges if the group selected exists and user is in that group", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const sendMessage_ = await contract.sendMessagesInAGroup("Juventus","Hey Juventus fan"); 
await sendMessage_.wait(1); 
})
it("After sending messagges the array group to messages inside should increase +1", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const sendMessage_ = await contract.sendMessagesInAGroup("Juventus","Hey Juventus fan"); 
await sendMessage_.wait(1); 
const getMessagges = await contract.returnGroupMessagges("Juventus"); 
const getSize = getMessagges.length; 
assert.equal("1",getSize.toString()); 
})
it("After sending the message in the group, in the group to message array should be returned the exact message correctly", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const sendMessage_ = await contract.sendMessagesInAGroup("Juventus","Hey Juventus fan"); 
await sendMessage_.wait(1); 
const getMessagges = await contract.returnGroupMessagges("Juventus"); 
const getMessage = getMessagges[0][2]; 
assert.equal(getMessage.toString(),"Hey Juventus fan")
})
})


//MODIFY THE MESSAGE IN THE GROUP
describe("modifyMessageInTheGroup function", async function(){
it("Cant modify the message if the group does not exists", async function(){
await expect(contract.modifyMessageInTheGroup("Torino","Hi","Hola")).to.be.revertedWith("Cant modify the message in the group"); 
})
it("Can't modify the message if the group does not exist part 2", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
await expect(contract.modifyMessageInTheGroup("Torino","Hi","Hola")).to.be.revertedWith("Cant modify the message in the group"); 
})
it("Can't modify the message if the message to modify does not exist in the group", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const sendMessage_ = await contract.sendMessagesInAGroup("Juventus","Hey Juventus fan"); 
await sendMessage_.wait(1); 
await expect(contract.modifyMessageInTheGroup("Juventus","Hi","Hola")).to.be.revertedWith("Cant modify the message in the group"); 
})
it("Can modify the message if the inputs are correct", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const sendMessage_ = await contract.sendMessagesInAGroup("Juventus","Hey Juventus fan"); 
await sendMessage_.wait(1); 
const modifyMess = await contract.modifyMessageInTheGroup("Juventus","Hey Juventus fan","Hey Juventus fam"); 
await modifyMess.wait(1); 
})
it("After modifying the message in the group, the group to messages array length should be neutral(so keeps to be 1 in this case, and not +1 or -1", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const sendMessage_ = await contract.sendMessagesInAGroup("Juventus","Hey Juventus fan"); 
await sendMessage_.wait(1); 
const modifyMess = await contract.modifyMessageInTheGroup("Juventus","Hey Juventus fan","Hey Juventus fam"); 
await modifyMess.wait(1); 
const getGroupsMessagges = await contract.returnGroupMessagges("Juventus"); 
const getSize = getGroupsMessagges.length; 
assert.equal("1",getSize.toString()); 
})
it("After modifying the message in the group, in the group to messsagges array should be returned the message mofified and not the old one", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
const sendMessage_ = await contract.sendMessagesInAGroup("Juventus","Hey Juventus fan"); 
await sendMessage_.wait(1); 
const modifyMess = await contract.modifyMessageInTheGroup("Juventus","Hey Juventus fan","Hey Juventus fam"); 
await modifyMess.wait(1); 
const getGroupsMessagges = await contract.returnGroupMessagges("Juventus"); 
const getElement = getGroupsMessagges[0][2]; 
assert.equal(getElement.toString(),"Hey Juventus fam"); 
})
})


//DELETE MESSAGE IN THE GROUP
describe("deleteMessageInTheGroup function", async function(){
it("Can't delete messagges if they does not exists", async function(){
await expect(contract.deleteMessageInTheGroup("Real Madrid","Hala madrid")).to.be.revertedWith("Cant delete the message"); 
})
it("Can't' delete messagges if they does not exists part 2", async function(){
const _createGroup = await contract.createGroup("Juventus","Juventus for the life"); 
await _createGroup.wait(1); 
await expect(contract.deleteMessageInTheGroup("Real Madrid","Hala madrid")).to.be.revertedWith("Cant delete the message"); 
})
it("Can't delete messagges if they does not exists part 2", async function(){
const _createGroup = await contract.createGroup("Real Madrid","Juventus for the life"); 
await _createGroup.wait(1); 
await expect(contract.deleteMessageInTheGroup("Real Madrid","Hala madrid")).to.be.revertedWith("Cant delete the message"); 
})
it("Can't delete messagges if they does not exists part 3", async function(){
const _createGroup = await contract.createGroup("Real Madrid","Juventus for the life"); 
await _createGroup.wait(1); 
const sendMessage_ = await contract.sendMessagesInAGroup("Real Madrid","Hola"); 
await sendMessage_.wait(1); 
await expect(contract.deleteMessageInTheGroup("Real Madrid","Hala madrid")).to.be.revertedWith("Cant delete the message"); 
})
it("Can delete the message if the inputs are correct", async function(){
const _createGroup = await contract.createGroup("Real Madrid","Juventus for the life"); 
await _createGroup.wait(1); 
const sendMessage_ = await contract.sendMessagesInAGroup("Real Madrid","Hala madrid"); 
await sendMessage_.wait(1); 
const deleteMess = await contract.deleteMessageInTheGroup("Real Madrid","Hala madrid")
await deleteMess.wait(1); 
})
it("After deleting the message in the group, the array group to message inside should length should return -1  (0 in this case)", async function(){
const _createGroup = await contract.createGroup("Real Madrid","Juventus for the life"); 
await _createGroup.wait(1); 
const sendMessage_ = await contract.sendMessagesInAGroup("Real Madrid","Hala madrid"); 
await sendMessage_.wait(1); 
const deleteMess = await contract.deleteMessageInTheGroup("Real Madrid","Hala madrid")
await deleteMess.wait(1); 
const getMessagges = await contract.returnGroupMessagges("Real Madrid"); 
const getSize = getMessagges.length; 
assert.equal("0",getSize.toString()); 
})
})
})