const TONTestingSuite = require("ton-testing-suite");


async function loadContract(tonWrapper, name, address) {
    await tonWrapper._setupTonClient()
    return await TONTestingSuite.requireContract(tonWrapper, name, address, process.env.ARTIFACTS_PATH);
}

module.exports = {
    loadAuctionRootContract: async function (tw) {
        return await loadContract(tw, process.env.AUCTION_ROOT_CONTRACT);
    },
    loadEnglishForwardAuctionContract: async function (tw) {
        return await loadContract(tw, 'EnglishForwardAuction');
    },
    loadEnglishReverseAuctionContract: async function (tw) {
        return await loadContract(tw, 'EnglishReverseAuction');
    },
    loadDutchForwardAuctionContract: async function (tw) {
        return await loadContract(tw, 'DutchForwardAuction');
    },
    loadDutchReverseAuctionContract: async function (tw) {
        return await loadContract(tw, 'DutchReverseAuction');
    },
    loadBlindForwardAuctionContract: async function (tw) {
        return await loadContract(tw, 'BlindForwardAuction');
    },
    loadBlindReverseAuctionContract: async function (tw) {
        return await loadContract(tw, 'BlindReverseAuction');
    },
    loadBlindBidContract: async function (tw) {
        return await loadContract(tw, 'BlindBid');
    },
    loadTestWalletContract: async function (tw) {
        return await loadContract(tw, process.env.TEST_WALLET_CONTRACT);
    },
    loadTestDeployerContract: async function (tw) {
        return await loadContract(tw, 'TestDeployer');
    },
}
