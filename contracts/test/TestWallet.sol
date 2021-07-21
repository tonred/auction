pragma ton-solidity >=0.39.0;

import "../abstract/EnglishAuction.sol";
import "../abstract/DutchAuction.sol";
import "../abstract/BlindAuction.sol";


contract TestWallet {

    constructor() public {
        tvm.accept();
    }

    function sendTransaction(
        address payable dest,
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


    fallback() external {}

    receive() external {}
}
