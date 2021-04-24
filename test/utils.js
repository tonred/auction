require('dotenv').config({path: './.env'});

const TONTestingSuite = require("ton-testing-suite");
const {ContractWrapper} = require("ton-testing-suite");

function loadTestingEnv() {
    console.log(process.env.NETWORK);

    const giverConfig = {
        address: process.env.GIVER_CONTRACT,
        abi: JSON.parse(process.env.GIVER_ABI),
    };
    const config = {
        messageExpirationTimeout: 60000
    };

    const tonWrapper = new TONTestingSuite.TonWrapper({
        network: process.env.NETWORK,
        seed: process.env.SEED,
        giverConfig,
        config,
        runAttempts: 3,
    });
    return {ARTIFACTS_PATH: process.env.ARTIFACTS_PATH, ALIAS: process.env.ALIAS, tonWrapper: tonWrapper}
}

function copyContract(contract) {
    return new ContractWrapper(
        contract.tonWrapper,
        contract.abi,
        contract.imageBase64
    );
}

module.exports = {
    loadTestingEnv: loadTestingEnv,
    copyContract: copyContract
}

