require('dotenv').config({path: './.env'});
const TONTestingSuite = require("ton-testing-suite");
const {loadTonWrapper} = require("./utils");
const {loadTestDeployerContract, loadAuctionRootContract} = require("./loadContracts");
const ALIAS = 'Test' + process.env.ALIAS;


async function deployTestDeployer(tonWrapper, migration) {
    const TestDeployerContract = await loadTestDeployerContract(tonWrapper);
    const auctionRootContract = await loadAuctionRootContract(tonWrapper);
    await auctionRootContract.loadMigration('AuctionRoot')
    await migration.deploy({
        contract: TestDeployerContract,
        constructorParams: {auctionRoot: auctionRootContract.address},
        initialBalance: TONTestingSuite.utils.convertCrystal('100', 'nano'),
        alias: 'TestDeployer',
    });
    await TestDeployerContract.run('deployAll', {
        repeats: 1,
        openDuration: 60 * 60 * 12,
        confirmationDuration: 60 * 60 * 12
    });
}

if (require.main === module) {
    (async () => {
        const _tonWrapper = await loadTonWrapper();
        await _tonWrapper.setup(1);
        const _migration = new TONTestingSuite.Migration(_tonWrapper);
        await deployTestDeployer(_tonWrapper, _migration)
        process.exit(0);
    })();
}


module.exports = {
    deployTestDeployer: deployTestDeployer
}
