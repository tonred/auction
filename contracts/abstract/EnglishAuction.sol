pragma ton-solidity >= 0.39.0;

import "./CommonAuction.sol";
import "../Lib.sol";


abstract contract EnglishAuction is CommonAuction {

    uint128 _startValue;
    uint128 _stepValue;
    uint128 _bidsCount;


    /***************
     * CONSTRUCTOR *
     **************/
    /*
    @param owner        Owner of this auction contract
    @param fee          Fee value for each bid
    @param startValue   Value when auction is started
    @param stepValue    Value on which next bid must be greater/lower
    @param startTime    Timestamp when auction will start
    @param openDuration Duration of auction in seconds
    */
    constructor(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot CommonAuction(owner, fee, startTime, openDuration) {
        require(stepValue > 0, Errors.LOW_STEP_VALUE);
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

    function makeBid(uint128 value) virtual public;

}
