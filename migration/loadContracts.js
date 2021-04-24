const TONTestingSuite = require("ton-testing-suite");


async function loadContract(tonWrapper, name, address) {
    await tonWrapper._setupTonClient()
    return await TONTestingSuite.requireContract(tonWrapper, name, address, process.env.ARTIFACTS_PATH);
}

module.exports = {
    loadAuctionContract: async function (tw) {
        return await loadContract(tw, process.env.AUCTION_CONTRACT);
    },
    loadAuctionRootContract: async function (tw) {
        return await loadContract(tw, process.env.AUCTION_ROOT_CONTRACT);
    },
    loadBidContract: async function (tw) {
        return await loadContract(tw, process.env.BID_CONTRACT);
    },
    loadTestWalletContract: async function (tw) {
        return await loadContract(tw, process.env.TEST_WALLET_CONTRACT);
    },
}
