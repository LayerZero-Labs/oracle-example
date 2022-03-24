const contractName = "Oracle";

function getDependencies() {
    return ["UltraLightNodeMock"]
}

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    const ultraLightNodeMock = await ethers.getContract("UltraLightNodeMock")

    await deploy(contractName, {
        from: deployer,
        args: [ultraLightNodeMock.address],
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = [contractName]
module.exports.dependencies = getDependencies()
