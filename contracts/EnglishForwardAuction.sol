pragma ton-solidity >= 0.39.0;

import "./abstract/Forward.sol";
import "./EnglishAuction.sol";


contract EnglishForwardAuction is EnglishAuction, Forward {

    constructor(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot EnglishAuction(startValue, stepValue, startTime, openDuration) {}

    function isHigher(uint128 value, uint128 highest, uint128 startValue, uint128 stepValue) public override(CommonAuction, Forward) pure returns (bool) {
        return Forward.isHigher(value, highest, startValue, stepValue);
    }

}
