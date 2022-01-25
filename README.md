# network-for-oracles
Test Network.sol for creating an Oracle and delivering the blockHash + receiptsRoot

### to install and test

```
npm install
npx hardhat test
npx hardhat deploy
```

### deploy to testnet, put a seed phrase in .env matching the format of .env.example
```
npx hardhat --network fuji deploy
npx hardhat --network fuji set-approved-address --address 0xaaaaa_YOUR_SIGNER_ADDRESS_aaaaaa
```
