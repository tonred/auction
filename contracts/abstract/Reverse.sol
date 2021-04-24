pragma ton-solidity >= 0.39.0;


contract Reverse {

    function isHigher(uint128 value, uint128 highest, uint128 startValue, uint128 stepValue) public virtual pure returns (bool) {
        return highest >= stepValue && value < highest - stepValue && value <= startValue;
    }

}
