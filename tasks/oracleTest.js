const MAINNET_ORACLES = require('../constants/oracle/mainnet/oracles.json')
const TESTNET_ORACLES = require('../constants/oracle/testnet/oracles.json')
const ULN_CHAIN_ID = require('../constants/ultraLightNode/testnet/uln.json')
const ChainKey = require('../constants/chainKey/chainKey.json')
let ChainId = require('../constants/chainId/chainId.json')

let chainKey;
const CHAIN_ID = { [chainKey in ChainKey]: ChainId } = {
    [ChainKey.RINKEBY]: ChainId.RINKEBY,
    [ChainKey.BSC_TESTNET]: ChainId.BSC_TESTNET,
    [ChainKey.FUJI]: ChainId.FUJI,
    [ChainKey.MUMBAI]: ChainId.MUMBAI,
    [ChainKey.ARBITRUM_RINKEBY]: ChainId.ARBITRUM_RINKEBY,
    [ChainKey.OPTIMISM_KOVAN]: ChainId.OPTIMISM_KOVAN,
    [ChainKey.FANTOM_TESTNET]: ChainId.FANTOM_TESTNET
}

function getEndpointIdByName(networkName) {
    return CHAIN_ID[networkName];
}

function sleep(millis) {
    return new Promise((resolve) => setTimeout(resolve, millis))
}

module.exports = async function (taskArgs, hre) {
    let signers = await ethers.getSigners();
    let owner = signers[0]
    console.log(`Oracle Address: ${owner.address}`)
    console.log({TESTNET_ORACLES})

    var blockHashesReceived = {}
    var blockHashesReceivedNotFromUs = []
    var receivedNotFromUs = 0

    let tx
    let srcChainId = getEndpointIdByName(hre.network.name);
    //--------------- GET THE ORACLE  -----------------------------------------------
    let LayerZeroOracleMock = await ethers.getContractFactory("Oracle")
    let oracleAddress = TESTNET_ORACLES[CHAIN_ID[hre.network.name]]
    console.log({oracleAddress})
    let oracle = await LayerZeroOracleMock.attach(oracleAddress);
    console.log(`Oracle attached to: ${oracle.address}`)

    // SUBSCRIBE TO GET ORACLE DLIVERY EVENTS
    let UltraLightNodeMock = await ethers.getContract("UltraLightNodeMock")
    let ultraLightNodeAddress = ULN_CHAIN_ID[CHAIN_ID[hre.network.name]]
    let ultraLightNode = await UltraLightNodeMock.attach(ultraLightNodeAddress);
    console.log(`uln address: ${ultraLightNode.address}`)
    ultraLightNode.on("HashReceived", (srcChainId, sender, confirmations, hash) => {
        // Emitted on every block change
        if(blockHashesReceived[hash]?.us) {
            blockHashesReceived[hash].recv = true
        } else {
            blockHashesReceivedNotFromUs.push(hash)
            receivedNotFromUs += 1
        }
        console.log(`HashReceived: ${srcChainId}, ${sender}, ${confirmations}, ${hash} | adding to send events`)
    })

    // 3. call notifyOracle
    let currentEvents = 0
    let started = parseInt(new Date().getTime() / 1000)
    let runningSeconds;
    for(let i = 0; i < taskArgs.n; ++i) {
        let outboundProof = 1
        let confirmations = 6
        let tries = 1
        let success = false
        while (!success) {
            try {
                tx = await (await oracle.notifyOracle(
                    srcChainId, outboundProof, confirmations
                )).wait()
                console.log(`... [${i}] notifyOracle(${srcChainId},${outboundProof},${confirmations}) | tx: ${tx.transactionHash}`)
                console.log(`added blockHash: ${tx.blockHash}`)
                blockHashesReceived[tx.blockHash] = { us: true, recv: false, txHash: tx.transactionHash };
            } catch (e) {
                tries += 1
                if(e.error?.message.includes('ProviderError')) {
                    console.log(e.error.message)
                } else {
                    console.log(e)
                }
                console.log(`notifyOracle() error >>> going for try ${tries}`)
                await sleep(2500)
                continue
            }
            success = true
        }
    }

    while (true) {
        currentEvents = 0 // await countEvents(ultraLightNodeMock)
        runningSeconds = parseInt(new Date().getTime() / 1000) - started

        let countReceived = 0
        let missing = []
        for(let h in blockHashesReceived){
            if(blockHashesReceived[h].recv){
                countReceived += 1
            } else if(blockHashesReceived[h].us) {
                let transaction = await ether.getTransaction(blockHashesReceived[h].txHash);
                await sleep(350)
                if(blockHashesReceivedNotFromUs.includes(transaction.blockHash)) {
                    console.log(`Reorg occurred -> tx.hash ${blockHashesReceived[h].txHash} was sent with blockHash: ${h}, but now in blockHash: ${transaction.blockHash}`)
                    countReceived += 1
                } else {
                    missing.push(h)
                }
            }
        }

        console.log("taskArgs.n: " + taskArgs.n + " countReceived: " + countReceived)
        if(taskArgs.n - countReceived <= 10) {
            console.log({missing})
        }

        console.table({
            network: hre.network.name,
            receivedNotFromUs,
            runningSeconds,
            countReceived,
            expecting : taskArgs.n,
            received: `${countReceived} / ${taskArgs.n}`
        })

        if(taskArgs.n  == countReceived){
            break
        }
        await sleep(5000)
    }
    console.log(`${hre.network.name} successfully received  ${taskArgs.n} < HashReceived events`)
}
