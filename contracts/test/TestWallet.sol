pragma ton-solidity >=0.39.0;

import "../EnglishAuction.sol";


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

    function makeBid(
        address dest,
        uint128 value,
//        bool bounce,
//        uint8 flags,
        uint128 bidValue
    ) public pure {
        tvm.accept();
//        TvmBuilder builder;
//        builder.store(bidValue);
//        TvmCell payload = builder.toCell();
        EnglishAuction(dest).makeBid{value: value}(bidValue);
//        dest.transfer(value, bounce, flags, payload);
    }


    fallback() external {}

    receive() external {}
}
