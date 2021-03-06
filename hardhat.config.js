require("dotenv").config();

require('hardhat-contract-sizer');
require("@nomiclabs/hardhat-waffle");
require("solidity-coverage");
require("hardhat-gas-reporter");
require("hardhat-deploy");
require("hardhat-deploy-ethers");

require("./tasks")

const { accounts } = require("./utils/network");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {

    solidity: "0.8.11",
    contractSizer: {
        alphaSort: false,
        runOnCompile: true,
        disambiguatePaths: false,
    },

    // for hardhat-deploy
    namedAccounts: {
        deployer: 0,
    },

    networks: {
        rinkeby: {
            //this is the public infura api key
            url: "https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
            chainId: 4,
            accounts: accounts(),
        },
        'bsc-testnet': {
            url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
            chainId: 97,
            accounts: accounts(),
        },
        fuji: {
            url: `https://api.avax-test.network/ext/bc/C/rpc`,
            chainId: 43113,
            accounts: accounts(),
        },
        mumbai: {
            url: "https://rpc-mumbai.maticvigil.com/",
            chainId: 80001,
            accounts: accounts(),
        },
        'arbitrum-rinkeby': {
            url: `https://rinkeby.arbitrum.io/rpc`,
            chainId: 421611,
            accounts: accounts(),
        },
        'optimism-kovan': {
            url: `https://kovan.optimism.io/`,
            chainId: 69,
            accounts: accounts(),
        },
        'fantom-testnet': {
            url: `https://rpc.testnet.fantom.network/`,
            chainId: 4002,
            accounts: accounts(),
        }
    }
};
