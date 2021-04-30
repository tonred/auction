pragma ton-solidity >= 0.39.0;

import "./abstract/EnglishAuction.sol";


contract EnglishForwardAuction is EnglishAuction {

    constructor(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot EnglishAuction(owner, fee, startValue, stepValue, startTime, openDuration) {}

    function makeBid(uint128 value) doUpdate inPhase(Phase.OPEN) override public {
        _checkBid(value);
        _reserve(0);

        if (_winner.owner != address(0)) {
            _winner.owner.transfer({value: _winner.value, flag: 1, bounce: false});
        }
        _winner = Bid(msg.sender, value);
        _bidsCount++;
        emit BidIsMade(msg.sender, value);
    }

    function _checkBid(uint128 value) private view {
        require(msg.value >= value + _fee, Errors.LOW_MSG_VALUE);

        if (_winner.owner == address(0)) {
            require(value >= _startValue, Errors.VALUE_LESS_THAN_START_VALUE);
        } else {
            uint128 highest = getWinnerValue();
            require(value >= highest + _stepValue, Errors.VALUE_LESS_THAN_STEP_FROM_HIGHEST_VALUE);
        }
    }

}
