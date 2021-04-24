const TONTestingSuite = require("ton-testing-suite");
const {loadAuctionRootContract, loadAuctionContract, loadBidContract} = require("./loadContracts");


async function deployAuctionRoot(tonWrapper, migration) {
    const auctionRootContract = await loadAuctionRootContract(tonWrapper);
    const auctionContract = await loadAuctionContract(tonWrapper);
    const bidContract = await loadBidContract(tonWrapper);
    await migration.deploy({
        contract: auctionRootContract,
        constructorParams: {
            auctionCode: auctionContract.code,
            bidCode: bidContract.code,
        },
        initialBalance: TONTestingSuite.utils.convertCrystal('100', 'nano'),
        alias: process.env.ALIAS,
    })
    return auctionRootContract
}

module.exports = {
    deployAuctionRoot: deployAuctionRoot
}
