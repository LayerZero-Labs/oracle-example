module.exports = async function (taskArgs, hre) {
    // load the deployed Oracle contract
    const Oracle = await ethers.getContractFactory("Oracle")
    const oracleAddr = (await hre.deployments.get("Oracle")).address
    const oracle = await Oracle.attach(oracleAddr)

    // set approval (if not yet set)
    let addr = taskArgs.address;
    let isApproved = await oracle.isApproved(addr)
    if (isApproved) {
        console.log(`oracle.setApprovedAddress(${addr} , true) | *its already approved*`)
    } else {
        let tx = await (await oracle.setApprovedAddress(addr, true)).wait(1)
        console.log(`oracle.setApprovedAddress(${addr} , true) | tx: ${tx.transactionHash}`)
    }
}
