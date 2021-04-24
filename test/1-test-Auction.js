const {expect} = require('chai');
const logger = require('mocha-logger');
const TONTestingSuite = require("ton-testing-suite");
const BigNumber = require('bignumber.js');
const {
    loadAuctionContract,
    loadAuctionRootContract,
    loadTestWalletContract
} = require("../migration/loadContracts");
const {loadTestingEnv, copyContract} = require("./utils");

const {ARTIFACTS_PATH, ALIAS, tonWrapper} = loadTestingEnv();

let auctionContract;
let auctionRootContract;
let testWalletContract;


describe('Test Domain Auction', async function () {
    this.timeout(12000000);

    before(async function () {
        await tonWrapper.setup();
        auctionContract = await loadAuctionContract(tonWrapper);
        auctionRootContract = await loadAuctionRootContract(tonWrapper);
        testWalletContract = await loadTestWalletContract(tonWrapper);
        await auctionContract.loadMigration(ALIAS);
        await auctionRootContract.loadMigration(ALIAS);
        await testWalletContract.loadMigration('Test' + ALIAS);
        logger.log(`Auction Root contract address: ${auctionRootContract.address}`);
        logger.log(`Test Wallet contract address: ${testWalletContract.address}`);
    });

    describe('Check Domain Auction initial configuration', async function () {
        let fee = 1e9, deposit = 10e9, openDuration = 10, confirmationDuration = 10, startTime;

        before(async function () {
            startTime = Math.round(Date.now() / 1000);
            await deployAuction(auctionRootContract, {
                fee: fee,
                deposit: deposit,
                startTime: startTime,
                openDuration: openDuration,
                confirmationDuration: confirmationDuration,
            }, 1e9);
            let auctionId = (await auctionContract.runLocal('getId')).toString();
            logger.log(`Auction with id=${auctionId} deployed to address: ${auctionContract.address}`);
        });

        it('Check phase', async function () {
            expect((await auctionContract.runLocal('getPhase')).toString())
                .to
                .equal('1', 'Wrong initial phase');
        });
        it('Check fake bid remove', async function () {
            await removeBid(auctionContract, 1e9, 10101);
            expect((await auctionContract.runLocal('getBidsCount')).toString())
                .to
                .equal('0', 'Fake bid must not be removed');
        });
        it('Check make bid', async function () {
            let value = 2e9;
            let salt = randomInt(0, Number.MAX_SAFE_INTEGER);
            let hash = BigNumber(await auctionContract.runLocal('calcBidHash', {
                value: value, salt: salt,
            })).toFixed();
            logger.log(`First bid: value=${value}, salt=${salt}, hash=${hash}`);
            await makeBid(auctionContract, hash, value);
            // expect((await auctionContract.runLocal('getBidsCount')).toString())
            //     .to
            //     .equal('1', 'First bid is not made');
        });
        // it('Check make bid', async function () {
        //     let salt = randomInt(0, Number.MAX_SAFE_INTEGER);
        //     let bidValue = 1111;
        //     let bidHash = BigNumber(await DomainAuction.runLocal('calcHash', {
        //         bidValue: bidValue, salt: salt,
        //     })).toFixed();
        //     logger.log(`First bid: value=${bidValue}, salt=${salt}, bidHash=${bidHash}`);
        //     await makeBid(DomainAuction, bidHash, value);
        //
        //     expect((await DomainAuction.runLocal('getCurrentBidsCount')).toString())
        //         .to
        //         .equal('1', 'First bids is not made');
        // })
    });

});


function randomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

async function deployAuction(contract, input, value) {
    const message = await encode_message_body(contract, 'deploy', input)
    await send(contract.address, message.body, value);
    auctionContract.address = (await auctionRootContract.runLocal('get')).toString();
}

async function makeBid(contract, hash, value) {
    const message = await encode_message_body(contract, 'makeBid', {hash: hash});
    return await send(contract.address, message.body, value);
}

async function removeBid(contract, value, hash) {
    const message = await encode_message_body(contract, 'removeBid', {hash: hash});
    return await send(contract.address, message.body, value);
}

async function encode_message_body(contract, function_name, input) {
    return await tonWrapper.ton.abi.encode_message_body({
        address: contract.address,
        abi: {
            type: 'Contract',
            value: contract.abi,
        },
        call_set: {
            function_name: function_name,
            input: input,
        },
        signer: {
            type: 'None',
        },
        is_internal: true,
    });
}

async function send(dest, payload, value) {
    return await testWalletContract.run('sendTransaction', {
        dest: dest,
        value: value,
        bounce: true,
        flags: 0,
        payload: payload,
    }, null);
}
