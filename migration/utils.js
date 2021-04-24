const TONTestingSuite = require("ton-testing-suite");

async function setupKeyPairs(keysAmount = 100) {
    if (!this.config.seed) {
        const entropy = `0x${TONTestingSuite.utils.genHexString(32)}`;

        const {
            phrase,
        } = await this.ton.crypto.mnemonic_from_entropy({
            entropy,
            word_count: 12,
        });

        this.config.seed = phrase;
    }

    const keysHDPaths = [...Array(keysAmount).keys()].map(i => `m/44'/396'/0'/0/${i}`);
    let keys = Array();
    for (const x of keysHDPaths) {
        let k = await this.ton.crypto.mnemonic_derive_sign_keys({
            dictionary: 1,
            wordCount: 12,
            phrase: this.config.seed,
            path: x,
        })
        keys.push(k);
    }
    this.keys = keys;
}

async function loadTonWrapper() {
    const giverConfig = {
        address: process.env.GIVER_CONTRACT,
        abi: JSON.parse(process.env.GIVER_ABI),
    };
    const config = {
        messageExpirationTimeout: 60000
    };
    console.log(process.env.NETWORK);

    const tonWrapper = new TONTestingSuite.TonWrapper({
        network: process.env.NETWORK,
        seed: process.env.SEED,
        giverConfig,
        config,
    });
    tonWrapper._setupKeyPairs = setupKeyPairs;
    return tonWrapper
}

module.exports = {
    setupKeyPairs: setupKeyPairs,
    loadTonWrapper: loadTonWrapper
};
