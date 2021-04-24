pragma ton-solidity >= 0.39.0;

import "./abstract/Reverse.sol";
import "./EnglishAuction.sol";


contract EnglishReverseAuction is EnglishAuction, Reverse {

    constructor(
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration
    ) public onlyRoot EnglishAuction(startValue, stepValue, startTime, openDuration) {}

    function isHigher(uint128 value, uint128 highest, uint128 startValue, uint128 stepValue) public override(CommonAuction, Reverse) pure returns (bool) {
        return Reverse.isHigher(value, highest, startValue, stepValue);
    }

}
