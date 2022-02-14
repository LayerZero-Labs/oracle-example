# LayerZero Oracle Example
Test UltraLightNode.sol for creating an Oracle and delivering the blockHash + receiptsRoot

This repo has some simple tests to demonstrate how an Oracle can deliver the updateHash() call to fulfil the LayerZero oracle job.

We use hardhat-deploy to push and maintain the contract information, and also provide a task to whitelist the singer (see below)
### to install and test 

Recently tested with `node v16.13.2`

```
npm install
npx hardhat test
npx hardhat deploy
```

### Deploy to testnet 
Be sure to put a seed phrase in .env matching the format of .env.example
```
npx hardhat --network fuji deploy
npx hardhat --network fuji set-approved-address --address 0xaaaaa_YOUR_SIGNER_ADDRESS_aaaaaa
```

### Notes 

The Oracle contract is the "Destination Whitelister" which approves the callling signer to deliver the updateHash() thru the Oracle contract itself.
This unifies the msg.sender which is used to store the data in the LayerZero contracts.

We also have a specification on gitbook here: 

```
https://layerzero.gitbook.io/layerzero-oracle-specification/
```
