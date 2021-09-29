pragma ton-solidity >= 0.39.0;

import "../interface/IAuctionRoot.sol";
import "../Lib.sol";
import "./ITIP3Manager.sol";


abstract contract BaseAuction is ITIP3Manager {
    uint8 constant SEND_ALL_GAS = 64;


    AuctionType static _type;
    address static _root;
    uint64 static _id;


    address _owner;
    Phase _phase;
    Bid _winner;

    address _finishAddress;
    TvmCell _finishPayload;


    /*************
     * MODIFIERS *
     *************/

    modifier onlyRoot() {
        require(msg.sender == _root, Errors.IS_NOT_ROOT);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, Errors.IS_NOT_OWNER);
        _;
    }

    modifier inPhase(Phase phase) {
        require(_phase == phase, Errors.WRONG_PHASE);
        _;
    }

    modifier inPhaseReturnable(Phase phase, uint128 tokens_amount, address sender_wallet) {
        if (_phase != phase) {
            if (tokens_amount > 0 && sender_wallet != address(0)) {  // if need to return tip3 tokens
                _transferTokens(sender_wallet, tokens_amount);
            }
            tvm.exit();
        }
        _;
    }


    /***************
     * CONSTRUCTOR *
     **************/

    constructor(address owner, address tip3_root) public onlyRoot ITIP3Manager(owner, tip3_root) {
        tvm.accept();
        _owner = owner;
        _phase = Phase.WAIT;
        _finishAddress = owner;
        _finishPayload = tvm.buildEmptyData(0);
    }


    /***********
     * GETTERS *
     **********/

    function getType() public view returns (AuctionType) {
        return _type;
    }

    function getRoot() public view returns (address) {
        return _root;
    }

    function getId() public view returns (uint64) {
        return _id;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function getPhase() public view returns (Phase) {
        return _phase;
    }


    /***********
     * METHODS *
     **********/

    function update() public virtual;

    function setFinishPayload(address dest, TvmCell payload) public onlyOwner {
        tvm.accept();
        _finishAddress = dest;
        _finishPayload = payload;
    }

    function _sendFinish() internal {
        _phase = Phase.CLOSE;
        BaseAuction(address(this)).finish();
    }

    function finish() public view {
        require(msg.sender == address(this), Errors.IS_NOT_SELF);
        tvm.accept();
        _reserve(0);
        IAuctionRoot(_root).finish{value: 0, flag: 128, bounce: false}(
            _type,
            _id,
            _winner,
            _finishAddress,
            _finishPayload
        );
    }

    function _reserve(uint128 additional) internal view {
        tvm.rawReserve(address(this).balance - msg.value + additional, 2);
    }

}
