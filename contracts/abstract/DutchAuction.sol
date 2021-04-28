pragma ton-solidity >= 0.39.0;

import "./CommonAuction.sol";
import "../Lib.sol";


abstract contract DutchAuction is CommonAuction {

    uint128 _startValue;
    uint128 _finishValue;


    constructor(
        uint128 fee,
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot CommonAuction(fee, startTime, openDuration) {
        _startValue = startValue;
        _finishValue = finishValue;
    }

    function getStartValue() public view returns (uint128) {
        return _startValue;
    }

    function getFinishValue() public view returns (uint128) {
        return _finishValue;
    }

    function getCurrentPrice() public view returns (uint128) {
        return uint128((int256(_startValue) - _finishValue) * (int256(_openTime.finishTime) - now) / (int256(_openTime.finishTime) - _openTime.startTime) + _finishValue);
    }

    function buy(uint128 value) virtual public;

}
