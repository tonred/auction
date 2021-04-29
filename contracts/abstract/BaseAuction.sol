pragma ton-solidity >= 0.39.0;

import "../interface/IAuctionRoot.sol";
import "../Lib.sol";


abstract contract BaseAuction {
    uint8 constant SEND_ALL_GAS = 64;
    uint128 constant LEAVE_VALUE = 10 nanoton;


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

    modifier inPhase(Phase p) {
        require(_phase == p, Errors.WRONG_PHASE);
        _;
    }


    constructor(address owner) public onlyRoot {
        tvm.accept();
        _owner = owner;
        _phase = Phase.WAIT;
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
        IAuctionRoot(_root).finish{value: address(this).balance - LEAVE_VALUE, flag: 0, bounce: false}
            (_type, _id, _winner, _finishAddress, _finishPayload);
    }

    function _reserve(uint128 additional) internal view {
        tvm.rawReserve(address(this).balance - msg.value + additional, 2);
    }

}
