pragma ton-solidity >=0.39.0;

import "../abstract/EnglishAuction.sol";
import "../abstract/DutchAuction.sol";
import "../abstract/BlindAuction.sol";


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

    function blindMakeBid(address dest, uint128 value, uint256 hash) public pure {
        tvm.accept();
        BlindAuction(dest).makeBid{value: value}(hash);
    }

    function blindRemoveBid(address dest, uint128 value, uint256 hash) public pure {
        tvm.accept();
        BlindAuction(dest).removeBid{value: value}(hash);
    }

    function blindConfirmBid(address dest, uint128 value, uint128 bidValue, uint256 salt) public pure {
        tvm.accept();
        BlindAuction(dest).confirmBid{value: value}(bidValue, salt);
    }


    fallback() external {}

    receive() external {}
}
