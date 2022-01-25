function getMnemonic(networkName) {
    if (networkName) {
        const mnemonic = process.env['MNEMONIC_' + networkName.toUpperCase()];
        if (mnemonic && mnemonic !== '') {
            return mnemonic;
        }
    }

    const mnemonic = process.env.MNEMONIC;
    if (!mnemonic || mnemonic === '') {
        return 'test test test test test test test test test test test junk';
    }
    return mnemonic;
}

function accounts(networkName) {
    return {mnemonic: getMnemonic(networkName)};
}

module.exports = {
    accounts
};
