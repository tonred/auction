pragma ton-solidity >= 0.39.0;

import "./EnglishAuction.sol";


contract EnglishReverseAuction is EnglishAuction {

    constructor(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot EnglishAuction(startValue, stepValue, startTime, openDuration) {}

    function makeBid(uint128 value) doUpdate inPhase(Phase.OPEN) override public {
        _checkBid(value);
        _winner = Bid(msg.sender, value);
        _bidsCount++;
    }

    function _checkBid(uint128 value) private view {
        require(msg.value >= BID_FEE, 223);

        if (_winner.owner == address(0)) {
            require(value <= _startValue, 224);
        } else {
            uint128 lowest = getWinnerValue();
            // `lowest` must not be less than `_stepValue`, otherwise we already have the least possible value
            require(lowest >= _stepValue && value <= lowest - _stepValue, 225);
        }
    }

}
