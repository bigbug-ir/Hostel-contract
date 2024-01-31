require("@nomicfoundation/hardhat-toolbox");
// require("@nomiclabs/hardhat-waffle");npm i --save-dev hardhat@latest
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  paths:{
    sources:"./contracts",
    test:"./test",
    script:"scripts",
    cache:"./cache",
    artifacts:"./artifacts"
  },
};
