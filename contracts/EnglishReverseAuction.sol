pragma ton-solidity >= 0.39.0;

import "./abstract/EnglishAuction.sol";


contract EnglishReverseAuction is EnglishAuction {

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
        _winner = Bid(msg.sender, value);
        _bidsCount++;
        msg.sender.transfer({value : 0, flag : SEND_ALL_GAS, bounce: false});
    }

    function _checkBid(uint128 value) private view {
        require(msg.value >= _fee, Errors.LOW_MSG_VALUE);

        if (_winner.owner == address(0)) {
            require(value <= _startValue, Errors.VALUE_MORE_THAN_START_VALUE);
        } else {
            uint128 lowest = getWinnerValue();
            // `lowest` must not be less than `_stepValue`, otherwise we already have the least possible value
            require(lowest >= _stepValue && value <= lowest - _stepValue, Errors.VALUE_MORE_THAN_STEP_FROM_LOWEST_VALUE);
        }
    }

}
