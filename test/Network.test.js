const { expect } = require("chai")

describe("Network for Oracle testing", () => {

    beforeEach(async () => {
        let signers = await ethers.getSigners();

        this.oracleSigner = signers[0];
        this.randomSigner = signers[1];

        // ...
        let Oracle = await ethers.getContractFactory('Oracle')
        let Network = await ethers.getContractFactory('Network')

        this.oracle = await Oracle.deploy()
        this.network = await Network.deploy()

        // updateBlockHeader() test params
        this.srcChainId = 10 // the source LayerZero chainId
        this.confirmations = 35 // the number of confirmations the oracle waited before delivery
        this.blockHash = '0x62d56fac42e933efa302134dfcd8110e3516e0740775636c08db18d53d87380d' // for evm -> 32 bytes, the blockhash
        this.data = '0xa5aa633e2c229440da69b2719c5830deddb8d98ee097f23545de9ac4921e96a3'  // for evm -> 32 bytes, the receiptsRoot
    })

    it("deliver the data to the Network.updateBlockHeader(), which performs the Oracle job", async () => {
        await this.oracle.setApprovedAddress(this.oracleSigner.address, true);
        // perform the Oracle job
        await this.network.updateBlockHeader(
            this.srcChainId,
            this.oracle.address,
            this.blockHash,
            this.confirmations,
            this.data
        )
    })

    it("deliver the data to the Network.updateBlockHeader(), by an un-approved signer reverts", async () => {
        // perform the Oracle job
        await expect(
            this.network.connect(this.randomSigner).updateBlockHeader(this.srcChainId, this.oracle.address, this.blockHash, this.confirmations, this.data)
        ).to.be.revertedWith('LayerZero: the calling Oracle is not approved for updateBlockHeader()')
    })

    it("deliver the data with the same number of confirmations reverts", async () => {
        await this.oracle.setApprovedAddress(this.oracleSigner.address, true);
        // perform the Oracle job successfully
        await this.network.updateBlockHeader(this.srcChainId, this.oracle.address, this.blockHash, this.confirmations, this.data)

        // perform the same Oracle job again
        await expect(
            this.network.connect(this.oracleSigner).updateBlockHeader(this.srcChainId, this.oracle.address, this.blockHash, this.confirmations, this.data)
        ).to.be.revertedWith('LayerZero: oracle data can only update if it has more confirmations')
    })

})
