pragma ton-solidity >=0.39.0;

import "../AuctionRoot.sol";


contract TestAuctionRoot is AuctionRoot {

    constructor(uint128 deployValue, uint128 defaultFeeValue, uint128 defaultDepositValue) public AuctionRoot(deployValue, defaultFeeValue, defaultDepositValue) {
        tvm.accept();
        _deployValue = 0;  // in order to pass `checkValue` modifier
        _defaultFeeValue = 1 ton;
        _defaultDepositValue = 10 ton;
    }


    function testDeployEnglishForwardAuction(uint128 startValue, uint128 stepValue, uint32 startTime, uint32 openDuration) public returns (address) {
        tvm.accept();
        AuctionRoot.deployEnglishForwardAuction(startValue, stepValue, startTime, openDuration);
        return address(0);
    }

    function testDeployEnglishReverseAuction(uint128 startValue, uint128 stepValue, uint32 startTime, uint32 openDuration) public returns (address) {
        tvm.accept();
        AuctionRoot.deployEnglishReverseAuction(startValue, stepValue, startTime, openDuration);
        return address(0);
    }

    function testDeployDutchForwardAuction(uint128 startValue, uint128 finishValue, uint32 startTime, uint32 openDuration) public returns (address) {
        tvm.accept();
        AuctionRoot.deployDutchForwardAuction(startValue, finishValue, startTime, openDuration);
        return address(0);
    }

    function testDeployDutchReverseAuction(uint128 startValue, uint128 finishValue, uint32 startTime, uint32 openDuration) public returns (address) {
        tvm.accept();
        AuctionRoot.deployDutchReverseAuction(startValue, finishValue, startTime, openDuration);
        return address(0);
    }

    function testDeployBlindForwardAuction(uint32 startTime, uint32 openDuration, uint32 confirmationDuration) public returns (address) {
        tvm.accept();
        AuctionRoot.deployBlindForwardAuction(startTime, openDuration, confirmationDuration);
        return address(0);
    }

    function testDeployBlindReverseAuction(uint32 startTime, uint32 openDuration, uint32 confirmationDuration) public returns (address) {
        tvm.accept();
        AuctionRoot.deployBlindReverseAuction(startTime, openDuration, confirmationDuration);
        return address(0);
    }


    function isInited() public view returns (bool) {
        return _inited;
    }

}
