require("@nomiclabs/hardhat-waffle");
require("dotenv").config(); 
require("hardhat-coverage"); 
require("@nomicfoundation/hardhat-verify"); 

const SEPHOLIA_URL = process.env.ETHEREUM_SEPHOLIA_URL; 
const privateKey = process.env.PRIVATE_KEY; 
const ETHERSCAN_ETHEREUM = process.env.ETHERSCAN_ETHEREUM; 

module.exports = {
  solidity: "0.8.7",

  networks:{
    sepholia:{
      url: SEPHOLIA_URL, 
       accounts: [privateKey], 
        chainId: 11155111, 
         },
         localhost:{
        url: "http://127.0.0.1:8545/", 
        chainId:31337,
         }
          },
          etherscan:{
          apiKey: ETHERSCAN_ETHEREUM
          }
           };
