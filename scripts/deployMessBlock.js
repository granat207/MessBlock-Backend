const { formatEther } = require("ethers/lib/utils");
const {ethers, run,  networks} = require("hardhat"); 

async function deploy(){
const signer = await ethers.getSigner(); 
const signerAddress = await signer.getAddress(); 
const balanceOfUser = await signer.getBalance(); 
console.log("User has "+ ethers.utils.formatEther(balanceOfUser)+ "eth")
const contractFactory = await ethers.getContractFactory("MessBlock"); 
const contract = await contractFactory.deploy(); 
console.log("Wait contract is deploying...."); 
await contract.deployed(); 
console.log("Contract deployed: address is " + contract.address); 

}
deploy(); 