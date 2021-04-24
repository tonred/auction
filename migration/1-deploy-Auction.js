const TONTestingSuite = require("ton-testing-suite");
const {loadAuctionContract, loadBidContract} = require("./loadContracts");


async function deployAuction(tonWrapper, migration) {
    const auctionContract = await loadAuctionContract(tonWrapper);
    const bidContract = await loadBidContract(tonWrapper);
    let currentTime = Math.round(Date.now() / 1000);
    await migration.deploy({
        contract: auctionContract,
        constructorParams: {
            fee: 10e9,
            deposit: 100e9,
            startTime: currentTime,
            openDuration: 30,
            confirmationDuration: 30,
            bidCode: bidContract.code,
        },
        initParams: {
            _root: '0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94',
            _id: 1,
        },
        initialBalance: TONTestingSuite.utils.convertCrystal('1', 'nano'),
        alias: process.env.ALIAS,
    })
    return auctionContract
}

module.exports = {
    deployAuction: deployAuction
}
