pragma ton -solidity >= 0.39.0;

import "./abstract/CommonAuction.sol";
import "./Lib.sol";


abstract contract DutchAuction is CommonAuction {

    uint128 _startValue;
    uint128 _finishValue;


    constructor(
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot CommonAuction(startTime, openDuration) {
        _startValue = startValue;
        _finishValue = finishValue;
    }

    function getStartValue() public view returns (uint128) {
        return _startValue;
    }

    function getFinishValue() public view returns (uint128) {
        return _finishValue;
    }

    function getCurrentPrice() public pure returns (uint128) {
        return (_openTime.finishTime - now) / (_openTime.finishTime - _openTime.startTime) * (_startValue - _finishValue) + _finishValue;
    }

    function buy(uint128 value) virtual public;

    function buy() public {
        require(canBuy(msg.value), 121);
        _winner = Bid(msg.sender, msg.value);
        _finish();
    }

    function canBuy(uint128 value) public view returns (bool) {
        uint128 current = getCurrentPrice();
        //        return isHigher(value, highest, _startValue, _stepValue);
    }

}
