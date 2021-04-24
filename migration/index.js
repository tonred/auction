require('dotenv').config({path: './.env'});
const TONTestingSuite = require('ton-testing-suite');
const {loadTonWrapper} = require("./utils");
const {setupKeyPairs} = require('./utils.js');
const {deployAuction} = require("./1-deploy-Auction");
const {deployAuctionRoot} = require("./2-deploy-AuctionRoot");
const {deployTestWallet} = require("./3-deploy-TestWallet");


(async () => {
    const tonWrapper = await loadTonWrapper();
    await tonWrapper.setup(10);

    const migration = new TONTestingSuite.Migration(tonWrapper);

    await deployAuction(tonWrapper, migration);
    await deployAuctionRoot(tonWrapper, migration);
    await deployTestWallet(tonWrapper, migration);

    process.exit(0);
})();
