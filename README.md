# LayerZero Oracle Example
Test UltraLightNode.sol for creating an Oracle and delivering the blockHash + receiptsRoot

This repo has some simple tests to demonstrate how an Oracle can deliver the updateHash() call to fulfil the LayerZero oracle job.

We use hardhat-deploy to push and maintain the contract information, and also provide a task to whitelist the singer (see below)

### Setup
- Copy .env.example to .env and fill in variables
- Fill in your oracle addresses in constants/oracle/testnet/oracles.json

### To install and test 

Recently tested with `node v16.13.2`

```
npm install
npx hardhat test
```

### Deploy to testnet 
Be sure to put a seed phrase in .env matching the format of .env.example
```
npx hardhat --network fuji deploy
npx hardhat --network fuji set-approved-address --address 0xaaaaa_YOUR_SIGNER_ADDRESS_aaaaaa
```

### Run loop back Oracle test
Whitelist any addresses that call notifyOracle and or updateHash. See `set-approved-address` command above.
```
npx hardhat --network fuji oracleTest --n 3
```
`--n` specifies how many tests you want to send.

### Notes 

The Oracle contract is the "Destination Whitelister" which approves the calling signer to deliver the updateHash() thru the Oracle contract itself.
This unifies the msg.sender which is used to store the data in the LayerZero contracts.

We also have a specification on gitbook here: 

```
https://layerzero.gitbook.io/layerzero-oracle-specification/
```
