pragma ton-solidity >= 0.39.0;

import "../Lib.sol";


abstract contract BaseAuction {


    address static _root;
    uint64 static _id;

    address _owner;
    Phase _phase;
    Bid _winner;


    /*************
     * MODIFIERS *
     *************/

    modifier onlyRoot() {
        require(msg.sender == _root, Errors.IS_NOT_ROOT);
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

    function _finish() internal {
        _phase = Phase.CLOSE;
        // todo proxy to root
    }

    function _reserve(uint128 additional) internal view {
        tvm.rawReserve(address(this).balance - msg.value + additional, 2);
    }

}
