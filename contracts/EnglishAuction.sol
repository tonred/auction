pragma ton-solidity >= 0.39.0;

import "./abstract/CommonAuction.sol";
import "./Lib.sol";


abstract contract EnglishAuction is CommonAuction {

    uint128 _startValue;
    uint128 _stepValue;
    uint128 _bidsCount;


    constructor(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot CommonAuction(startTime, openDuration) {
        require(stepValue > 0, 1012);
        _startValue = startValue;
        _stepValue = stepValue;
    }

    function getStartValue() public view returns (uint128) {
        return _startValue;
    }

    function getStepValue() public view returns (uint128) {
        return _stepValue;
    }

    function getBidsCount() public view returns (uint128) {
        return _bidsCount;
    }

    function getWinnerValue() public view returns (uint128) {
        return _winner.value;
    }

//    function getBestBidValue() public view returns (uint128) {
//        return _bidsCount == 0 ? _startValue : _winner.value + _stepValue;  // todo reverse support
//    }

    function makeBid(uint128 value) virtual public;

}
