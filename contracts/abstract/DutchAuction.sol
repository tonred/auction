pragma ton-solidity >= 0.39.0;

import "./CommonAuction.sol";
import "../Lib.sol";


abstract contract DutchAuction is CommonAuction {

    uint128 _startValue;
    uint128 _finishValue;


    /***************
     * CONSTRUCTOR *
     **************/
    /*
    @param owner        Owner of this auction contract
    @param fee          Fee value for each bid
    @param startValue   Value when auction is started
    @param finishValue  Value when auction is finished
    @param startTime    Timestamp when auction will start
    @param openDuration Duration of auction in seconds
    @param tip3_root    Address of TIP3 root contract
    */
    constructor(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration,
        address tip3_root
    ) public onlyRoot CommonAuction(owner, fee, startTime, openDuration, tip3_root) {
        _startValue = startValue;
        _finishValue = finishValue;
    }

    function getStartValue() public view returns (uint128) {
        return _startValue;
    }

    function getFinishValue() public view returns (uint128) {
        return _finishValue;
    }

    // Get price on what you can buy now
    function getCurrentPrice() public view returns (uint128) {
        return uint128((int256(_startValue) - _finishValue) * (int256(_openTime.finishTime) - now) / (int256(_openTime.finishTime) - _openTime.startTime) + _finishValue);
    }

}
