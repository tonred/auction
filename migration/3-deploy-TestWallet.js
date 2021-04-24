require('dotenv').config({path: './.env'});
const TONTestingSuite = require("ton-testing-suite");
const {loadTonWrapper} = require("./utils");
const {loadTestWalletContract} = require("./loadContracts");
const ALIAS = 'Test' + process.env.ALIAS;


async function deployTestWallet(tonWrapper, migration) {
    const TestWalletContract = await loadTestWalletContract(tonWrapper);
    await migration.deploy({
        contract: TestWalletContract,
        constructorParams: {},
        initialBalance: TONTestingSuite.utils.convertCrystal('10000', 'nano'),
        alias: ALIAS,
    });
}

module.exports = {
    deployTestWallet: deployTestWallet
}
