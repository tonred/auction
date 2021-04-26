pragma ton-solidity >=0.39.0;

import "../abstract/EnglishAuction.sol";
import "../abstract/DutchAuction.sol";


contract TestWallet {
    constructor() public {
        tvm.accept();
    }

    function sendGrams(address dest, uint64 amount) public pure {
        tvm.accept();
        dest.transfer({value: amount, bounce: false});
    }

    function sendTransaction(
        address dest,
        uint128 value,
        bool bounce,
        uint8 flags,
        TvmCell payload
    ) public pure {
        tvm.accept();
        dest.transfer(value, bounce, flags, payload);
    }

    function update(address dest, uint128 value) public pure {
        tvm.accept();
        BaseAuction(dest).update{value: value}();
    }

    function makeBid(address dest, uint128 value, uint128 bidValue) public pure {
        tvm.accept();
        EnglishAuction(dest).makeBid{value: value}(bidValue);
    }

    function buy(address dest, uint128 value, uint128 bidValue) public pure {
        tvm.accept();
        DutchAuction(dest).buy{value: value}(bidValue);
    }


    fallback() external {}

    receive() external {}
}
