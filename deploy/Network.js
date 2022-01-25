const contractName = "Network";
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    await deploy(contractName, {
        from: deployer,
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = [contractName]
