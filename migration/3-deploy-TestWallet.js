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

if (require.main === module) {
    (async () => {
        const _tonWrapper = await loadTonWrapper();
        await _tonWrapper.setup(1);
        const _migration = new TONTestingSuite.Migration(_tonWrapper);
        await deployTestWallet(_tonWrapper, _migration)
        process.exit(0);
    })();
}

module.exports = {
    deployTestWallet: deployTestWallet
}
