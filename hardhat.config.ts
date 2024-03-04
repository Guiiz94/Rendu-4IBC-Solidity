import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@nomiclabs/hardhat-ethers';
import '@typechain/hardhat';
import '@nomicfoundation/hardhat-chai-matchers';

require("@nomicfoundation/hardhat-chai-matchers");

export default {
  solidity: "0.8.0",
  typechain: {
    outDir: 'typechain',
    target: 'ethers-v5',
  },
};



