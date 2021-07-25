pragma ton-solidity >= 0.39.0;

import "./BaseAuction.sol";
import "../Lib.sol";


abstract contract CommonAuction is BaseAuction {

    uint128 _fee;
    PhaseTime _openTime;


    /**********
     * EVENTS *
     **********/

    event BidIsMade(address bettor, uint128 value);


    /*************
     * MODIFIERS *
     *************/

    modifier doUpdate() {
        _update();
        _;
    }


    /***************
     * CONSTRUCTOR *
     **************/

    constructor(
        address owner,
        uint128 fee,
        uint32 startTime,
        uint32 openDuration,
        address tip3_root
    ) public onlyRoot BaseAuction(owner, tip3_root) {
        require(openDuration > 0, Errors.LOW_OPEN_DURATION);
        _fee = fee;
        _openTime = PhaseTime(startTime, startTime + openDuration);
        _update();
    }


    /***********
     * GETTERS *
     **********/

    function getOpenTime() public view returns (PhaseTime) {
        return _openTime;
    }


    /******************
     * UPDATE METHODS *
     *****************/

    function updateAndGetPhase() public view doUpdate returns (Phase) {
        return _phase;
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
            _sendFinish();
        }
    }

}
