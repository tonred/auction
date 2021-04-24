pragma ton-solidity >= 0.39.0;

import "./BaseAuction.sol";
import "../Lib.sol";


abstract contract CommonAuction is BaseAuction {

    PhaseTime _openTime;


    constructor(uint32 startTime, uint32 openDuration) public onlyRoot BaseAuction() {
        require(openDuration > 0, 11);
        _openTime = PhaseTime(startTime, startTime + openDuration);
        update();
    }

    function getOpenTime() public view returns (PhaseTime) {
        return _openTime;
    }

    function update() public override {
        if (_phase == Phase.WAIT && now >= _openTime.startTime) {
            _phase = Phase.OPEN;
        }
        if (_phase == Phase.OPEN && now >= _openTime.finishTime) {
            _phase = Phase.CLOSE;
            _finish();
        }
    }

    function isHigher(uint128, uint128, uint128, uint128) public virtual pure returns (bool) {
        require(false, 1101);  // todo not implemented
        return false;
    }

//    function isLower(uint128, uint128, uint128, uint128) public virtual pure returns (bool) {
//        return !isHigher();
//    }

}
