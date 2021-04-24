pragma ton-solidity >= 0.39.0;

import "../Lib.sol";


abstract contract BaseAuction {

    uint128 BID_FEE = 1 ton;


    address static _root;
    uint64 static _id;

    Phase _phase;
    Bid _winner;


    /*************
     * MODIFIERS *
     *************/

    modifier onlyRoot() {
        require(msg.sender == _root, 1009);
        _;
    }

    modifier inPhase(Phase p) {
        require(_phase == p, 10101);
        _;
    }

    modifier doUpdate() virtual {
        require(false, 125);  // todo not implemented
        _;
    }


    constructor() public onlyRoot {
        tvm.accept();
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

    function getPhase() public view returns (Phase) {
        return _phase;
    }

    function _finish() internal view {  // todo ?????
        // todo proxy to root
    }

    function update() public virtual;

}
