pragma ton-solidity >=0.39.0;

import "../AuctionRoot.sol";


contract TestAuctionRoot is AuctionRoot {

    constructor(uint128 deployValue, uint128 defaultFeeValue, uint128 defaultDepositValue) public AuctionRoot(deployValue, defaultFeeValue, defaultDepositValue) {
        tvm.accept();
        _deployValue = 0;  // in order to pass `checkValue` modifier
    }


    function deployEnglishForwardAuction(uint128 startValue, uint128 stepValue, uint32 startTime, uint32 openDuration) override public returns (address) {
        tvm.accept();
        return AuctionRoot.deployEnglishForwardAuction(startValue, stepValue, startTime, openDuration);
    }

    function deployEnglishReverseAuction(uint128 startValue, uint128 stepValue, uint32 startTime, uint32 openDuration) override public returns (address) {
        tvm.accept();
        return AuctionRoot.deployEnglishReverseAuction(startValue, stepValue, startTime, openDuration);
    }

    function deployDutchForwardAuction(uint128 startValue, uint128 finishValue, uint32 startTime, uint32 openDuration) override public returns (address) {
        tvm.accept();
        return AuctionRoot.deployDutchForwardAuction(startValue, finishValue, startTime, openDuration);
    }

    function deployDutchReverseAuction(uint128 startValue, uint128 finishValue, uint32 startTime, uint32 openDuration) override public returns (address) {
        tvm.accept();
        return AuctionRoot.deployDutchReverseAuction(startValue, finishValue, startTime, openDuration);
    }

    function deployBlindForwardAuction(uint32 startTime, uint32 openDuration, uint32 confirmationDuration) override public returns (address) {
        tvm.accept();
        return AuctionRoot.deployBlindForwardAuction(startTime, openDuration, confirmationDuration);
    }

    function deployBlindReverseAuction(uint32 startTime, uint32 openDuration, uint32 confirmationDuration) override public returns (address) {
        tvm.accept();
        return AuctionRoot.deployBlindReverseAuction(startTime, openDuration, confirmationDuration);
    }


    function isInited() public view returns (bool) {
        return _inited;
    }

}
