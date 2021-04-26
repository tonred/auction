pragma ton -solidity >= 0.39.0;

import "./DutchAuction.sol";


contract DutchForwardAuction is DutchAuction {

    constructor(
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot DutchAuction(startValue, finishValue, startTime, openDuration) {
        require(startValue < finishValue);
    }

    function buy(uint128 value) doUpdate inPhase(Phase.OPEN) override public {
        _canBuy(value);
        _winner = Bid(msg.sender, msg.value);
        _finish();
        // todo reserve ++ (q1?)
    }

    function _canBuy(uint128 value) private view {
        require(msg.value >= BID_FEE, 123);
        require(value <= getCurrentPrice(), 125);
    }

}
