require('dotenv').config({path: './.env'});
const TONTestingSuite = require("ton-testing-suite");
const {loadTonWrapper} = require("./utils");
const { loadDeBotContract, loadAuctionRootContract} = require("./loadContracts");


async function deployAuctionDeBot(tonWrapper, migration) {
    const AuctionRootContract = await loadAuctionRootContract(tonWrapper);
    const AuctionDeBotContract = await loadDeBotContract(tonWrapper);
    await AuctionRootContract.loadMigration('AuctionRoot');
    await migration.deploy({
        contract: AuctionDeBotContract,
        constructorParams: {
            debotAbi: TONTestingSuite.utils.stringToBytesArray(JSON.stringify(AuctionDeBotContract.abi)),
            targetAddress: AuctionRootContract.address,
        },
        initParams: {},
        initialBalance: TONTestingSuite.utils.convertCrystal('1', 'nano'),
        alias: 'DeBot',
    });
    return AuctionDeBotContract

}

if (require.main === module) {
    (async () => {
        const _tonWrapper = await loadTonWrapper();
        await _tonWrapper.setup(1);
        const _migration = new TONTestingSuite.Migration(_tonWrapper);
        await deployAuctionDeBot(_tonWrapper, _migration)
        process.exit(0);
    })();
}

module.exports = {
    deployAuctionDeBot: deployAuctionDeBot
}
