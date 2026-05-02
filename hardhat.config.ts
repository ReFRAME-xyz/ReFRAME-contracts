import "dotenv/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ethers";
import { HttpNetworkUserConfig } from "hardhat/types";
import {
  HardhatUserConfig,
  HttpNetworkAccountsUserConfig,
} from "hardhat/types";
import "@nomicfoundation/hardhat-ignition-ethers";

const PRIVATE_KEY = process.env.PRIVATE_KEY;

const accounts: HttpNetworkAccountsUserConfig | undefined = PRIVATE_KEY
  ? [PRIVATE_KEY]
  : undefined;

if (accounts == null) {
  console.warn(
    "Could not find MNEMONIC or PRIVATE_KEY environment variables. It will not be possible to execute transactions in your example."
  );
}

const networks: { [networkName: string]: HttpNetworkUserConfig } = {
  base: {
    url: "https://mainnet.base.org",
    chainId: 8453,
    accounts,
  }
};

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    ...networks,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.24",
        settings: {
          evmVersion: "cancun",
          optimizer: {
            enabled: true,
            runs: 200,
          },
          viaIR: true,
          // outputSelection: {
          //   "*": {
          //     "*": [
          //       // "abi",
          //       // "evm.bytecode",
          //       // "evm.deployedBytecode",
          //       "metadata", // <-- add this
          //     ]
          //   },
          // },
        },
      },
    ],
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 40000,
  },
  etherscan: {
    apiKey: {
      base: process.env.BASESCAN || "",
    },
    customChains: [
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL: `https://api.etherscan.io/v2/api?chainid=8453`,
          browserURL: "https://basescan.org/",
        },
      }
    ],
  }
};

export default config;
