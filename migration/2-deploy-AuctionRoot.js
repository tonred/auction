require('dotenv').config({path: './.env'});
const TONTestingSuite = require("ton-testing-suite");
const {loadTonWrapper} = require("./utils");
const {
    loadAuctionRootContract,
    loadEnglishForwardAuctionContract,
    loadEnglishReverseAuctionContract,
    loadDutchForwardAuctionContract,
    loadDutchReverseAuctionContract,
    loadBlindForwardAuctionContract,
    loadBlindReverseAuctionContract,
    loadBlindBidContract
} = require("./loadContracts");


async function deployAuctionRoot(tonWrapper, migration) {
    const auctionRootContract = await loadAuctionRootContract(tonWrapper);
    const EnglishForwardAuctionContract = await loadEnglishForwardAuctionContract(tonWrapper);
    const EnglishReverseAuctionContract = await loadEnglishReverseAuctionContract(tonWrapper);
    const DutchForwardAuctionContract = await loadDutchForwardAuctionContract(tonWrapper);
    const DutchReverseAuctionContract = await loadDutchReverseAuctionContract(tonWrapper);
    const BlindForwardAuctionContract = await loadBlindForwardAuctionContract(tonWrapper);
    const BlindReverseAuctionContract = await loadBlindReverseAuctionContract(tonWrapper);
    const BlindBidContract = await loadBlindBidContract(tonWrapper);
    await migration.deploy({
        contract: auctionRootContract,
        constructorParams: {
            deployValue: TONTestingSuite.utils.convertCrystal('1', 'nano'),
            defaultFeeValue: TONTestingSuite.utils.convertCrystal('1', 'nano'),
            defaultDepositValue: TONTestingSuite.utils.convertCrystal('10', 'nano'),
        },
        initialBalance: TONTestingSuite.utils.convertCrystal('2', 'nano'),
        alias: 'AuctionRoot',
    })

    async function init(name, value) {
        console.log('AuctionRootContract initialization: ' + name);
        await auctionRootContract.run(name, value);
    }

    await init('setCodeEnglishForwardAuction', {code: EnglishForwardAuctionContract.code});
    await init('setCodeEnglishReverseAuction', {code: EnglishReverseAuctionContract.code});
    await init('setCodeDutchForwardAuction', {code: DutchForwardAuctionContract.code});
    await init('setCodeDutchReverseAuction', {code: DutchReverseAuctionContract.code});
    await init('setCodeBlindForwardAuction', {code: BlindForwardAuctionContract.code});
    await init('setCodeBlindReverseAuction', {code: BlindReverseAuctionContract.code});
    await init('setCodeBlindBid', {code: BlindBidContract.code});
    await init('finishInit', {});
}

if (require.main === module) {
    (async () => {
        const _tonWrapper = await loadTonWrapper();
        await _tonWrapper.setup(1);
        const _migration = new TONTestingSuite.Migration(_tonWrapper);
        await deployAuctionRoot(_tonWrapper, _migration)
        process.exit(0);
    })();
}


module.exports = {
    deployAuctionRoot: deployAuctionRoot
}
