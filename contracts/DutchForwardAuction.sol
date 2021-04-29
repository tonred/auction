pragma ton-solidity >= 0.39.0;

import "./abstract/DutchAuction.sol";


contract DutchForwardAuction is DutchAuction {

    constructor(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot DutchAuction(owner, fee, startValue, finishValue, startTime, openDuration) {
        require(startValue > finishValue, Errors.START_LESS_THAN_FINISH);
    }

    function buy(uint128 value) doUpdate inPhase(Phase.OPEN) override public {
        _canBuy(value);
        _winner = Bid(msg.sender, msg.value);
        _sendFinish();
    }

    function _canBuy(uint128 value) private view {
        require(msg.value >= value + _fee, Errors.LOW_MSG_VALUE);
        require(value >= getCurrentPrice(), Errors.VALUE_LESS_THAN_CURRENT_PRICE);
    }

}
