pragma ton-solidity >= 0.39.0;

import "../EnglishForwardAuction.sol";


contract EnglishForwardAuctionTest is EnglishForwardAuction {

    constructor(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot EnglishForwardAuction(startValue, stepValue, startTime, openDuration) {}

    function update() override public {
        tvm.accept();
        CommonAuction.update();
    }

    function makeBid(uint128 value) override public {
        tvm.accept();
        EnglishForwardAuction.makeBid(value);
    }

}
