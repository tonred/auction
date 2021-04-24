pragma ton -solidity >= 0.39.0;

import "./abstract/Forward.sol";
import "./EnglishAuction.sol";


contract EnglishForwardAuction is EnglishAuction {

    constructor(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot EnglishAuction(startValue, stepValue, startTime, openDuration) {}

    function makeBid(uint128 value) inPhase(Phase.OPEN) doUpdate override virtual public {
        require(_canMakeBid(value), 199);
        if (_winner.owner != address(0)) {
            _winner.owner.transfer(_winner.value);
        }
        _winner = Bid(msg.sender, value);
        _bidsCount++;
    }

    function _canMakeBid(uint128 value) private view returns (bool) {
        if (msg.value < value + BID_FEE) {
            return false;
        }

        if (_winner.owner == address(0)) {
            return value >= _startValue;
        } else {
            uint128 highest = getWinnerValue();
            return value >= highest + _stepValue;
        }
    }

}
