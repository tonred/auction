pragma ton-solidity >= 0.39.0;

import "./BaseAuction.sol";
import "../Lib.sol";


abstract contract CommonAuction is BaseAuction {


    PhaseTime _openTime;


    modifier doUpdate() {
        _update();
        _;
    }

    constructor(uint32 startTime, uint32 openDuration) public onlyRoot BaseAuction() {
        require(openDuration > 0, Errors.LOW_OPEN_DURATION);
        _openTime = PhaseTime(startTime, startTime + openDuration);
        _update();
    }

    function getOpenTime() public view returns (PhaseTime) {
        return _openTime;
    }

    function update() doUpdate override virtual public {
        msg.sender.transfer({value: 0, flag: 64, bounce: false});
    }

    function _update() private {
        if (_phase == Phase.WAIT && now >= _openTime.startTime) {
            _phase = Phase.OPEN;
        }
        if (_phase == Phase.OPEN && now >= _openTime.finishTime) {
            _phase = Phase.CLOSE;
            _finish();
        }
    }

}
