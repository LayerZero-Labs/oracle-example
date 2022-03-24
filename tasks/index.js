task("set-approved-address", "whitelist addresses to sign on behalf of the oracle", require("./setApprovedAddress"))
    .addParam("address", "signer address")

task("oracleTest", "test oracle", require("./oracleTest"))
    .addOptionalParam("n", "the number of notifyOracle() calls to make", 1, types.int)