pragma ton-solidity >= 0.39.0;

import "./BaseAuction.sol";
import "../BlindBid.sol";
import "../Lib.sol";


abstract contract BlindAuction is BaseAuction {
    uint128 constant DEPLOY_BID_VALUE = 0.5 ton;
    uint32 UINT32MAX = 2 ** 32 - 1;


    uint128 _fee;
    uint128 _deposit;

    PhaseTime _openTime;
    PhaseTime _confirmationTime;

    TvmCell _bidCode;

    uint128 _bidsHashesCount;
    uint128 _bidsCount;


    /*************
     * MODIFIERS *
     *************/

    modifier doUpdate() {
        if (_phase == Phase.WAIT && now >= _openTime.startTime) {
            _phase = Phase.OPEN;
        }
        if (_phase == Phase.OPEN && now >= _confirmationTime.startTime) {
            _phase = Phase.CONFIRMATION;
        }
        if (_phase == Phase.CONFIRMATION && now >= _confirmationTime.finishTime) {
            _phase = Phase.CLOSE;
            _finish();
        }
        _;
    }


    /***************
     * CONSTRUCTOR *
     **************/
    /*
    @param fee                  Non-returnable fee value for each bid
    @param deposit              Returnable deposit value for each bid
    @param startTime            Timestamp when auction will start
    @param openDuration         Duration of open phase in seconds
    @param confirmationDuration Duration of confirmation phase in seconds
    @param bidCode              Code of bid contract
    */
    constructor(
        address owner,
        uint128 fee,
        uint128 deposit,
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration,
        TvmCell bidCode
    ) public onlyRoot BaseAuction(owner) {
        require(fee > DEPLOY_BID_VALUE, Errors.LOW_FEE_VALUE);
        require(deposit > fee, Errors.LOW_DEPOSIT_VALUE);
        tvm.accept();
        _fee = fee;
        _deposit = deposit;
        _phase = Phase.WAIT;
        _setupPhasesTime(startTime, openDuration, confirmationDuration);
        _bidCode = bidCode;
        update();
    }

    // Used only in constructor
    function _setupPhasesTime(uint32 startTime, uint32 openDuration, uint32 confirmationDuration) private {
        uint32 splitTime = startTime + openDuration;
        uint32 finishTime = splitTime + confirmationDuration;
        _openTime = PhaseTime(startTime, splitTime);
        _confirmationTime = PhaseTime(splitTime, finishTime);
    }


    /***********
     * GETTERS *
     **********/

    function getOpenTime() public view returns (PhaseTime) {
        return _openTime;
    }

    function getConfirmationTime() public view returns (PhaseTime) {
        return _confirmationTime;
    }

    function getBidsCount() public view returns (uint128) {
        return _bidsHashesCount;
    }

    function getConfirmedBidsCount() public view returns (uint128) {
        return _bidsCount;
    }


    /******************
     * PUBLIC METHODS *
     *****************/

    /*
    @param hash Bid hash (can be calculated via `calcBidHash` method)
    @value Must be more than deposit
    */
    function makeBid(uint256 hash) public doUpdate inPhase(Phase.OPEN) {
        require(msg.value >= _deposit, Errors.VALUE_LESS_THAN_DEPOSIT);
        TvmCell stateInit = _buildBidStateInit(msg.sender, hash);
        new BlindBid{
            stateInit : stateInit,
            value : DEPLOY_BID_VALUE
        }();
        _bidsHashesCount++;
        msg.sender.transfer(msg.value - _deposit);
    }

    /*
    @param hash Bid hash (can be calculated via `calcBidHash` method)
    @value Must be enough for all gas used in this operation
    */
    function removeBid(uint256 hash) public view doUpdate inPhase(Phase.OPEN) {
        address bidAddress = _calcBidAddress(msg.sender, hash);
        BlindBid(bidAddress).remove{
            value: 0,
            callback: removeBidCallback
        }();
        msg.sender.transfer({value : 0, flag : SEND_ALL_GAS, bounce: false});
    }

    function removeBidCallback(address owner, uint256 hash) public {
        _checkIsBidCallback(owner, hash);
        _bidsHashesCount--;
        owner.transfer(_deposit - _fee);
    }

    function confirmBid(uint128 value, uint256 salt) virtual public view;

    function update() doUpdate override virtual public {
        msg.sender.transfer({value: 0, flag: SEND_ALL_GAS, bounce: false});
    }

    /*
    Calculates hash of bid value
    Can be used off-chain before `makeBid` function
    @param value Bid value
    @param salt  Random 128-bit value (please use really random number)
    @return 256-bit hash
    */
    function calcBidHash(uint128 value, uint256 salt) public pure returns (uint256) {
        TvmBuilder builder;
        builder.store(value, salt);
        TvmCell cell = builder.toCell();
        return tvm.hash(cell);
    }


    /***********
     * PRIVATE *
     **********/

    function _checkIsBidCallback(address owner, uint256 hash) internal view {
        address bidAddress = _calcBidAddress(owner, hash);
        require(msg.sender == bidAddress, Errors.IS_NOT_FROM_BID);
    }

    function _calcBidAddress(address owner, uint256 hash) internal view returns (address) {
        TvmCell stateInit = _buildBidStateInit(owner, hash);
        return _calcAddress(stateInit);
    }

    function _buildBidStateInit(address owner, uint256 hash) private view returns (TvmCell) {
        return tvm.buildStateInit({
            contr: BlindBid,
            varInit: {
                _auction : address(this),
                _owner : owner,
                _hash: hash
            },
            code : _bidCode
        });
    }

    function _calcAddress(TvmCell stateInit) private pure returns (address) {
        return address.makeAddrStd(0, tvm.hash(stateInit));
    }

    function _updateResults(Bid bid) virtual internal;

}
