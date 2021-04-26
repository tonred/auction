pragma ton -solidity >= 0.39.0;

import "./abstract/EnglishAuction.sol";


contract EnglishForwardAuction is EnglishAuction {

    constructor(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot EnglishAuction(startValue, stepValue, startTime, openDuration) {}

    function makeBid(uint128 value) doUpdate inPhase(Phase.OPEN) override public {
        _checkBid(value);
//        _reserve(value - _winner.value);  // todo ??? q1
        if (_winner.owner != address(0)) {
            _winner.owner.transfer(_winner.value);
        }
        _winner = Bid(msg.sender, value);
        _bidsCount++;
//        msg.sender.transfer({value: 0, flag: 64, bounce: false}); // todo ??? q1
    }

    function _checkBid(uint128 value) private view {
        require(msg.value >= value + BID_FEE, Errors.LOW_MSG_VALUE);

        if (_winner.owner == address(0)) {
            require(value >= _startValue, Errors.VALUE_LESS_THAN_START_VALUE);
        } else {
            uint128 highest = getWinnerValue();
            require(value >= highest + _stepValue, Errors.VALUE_LESS_THAN_STEP_FROM_HIGHEST_VALUE);
        }
    }

}
