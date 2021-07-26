pragma ton-solidity >=0.39.0;

pragma AbiHeader time;
pragma AbiHeader expire;

import "../abstract/BaseAuction.sol";


contract TestWallet {

    constructor() public {
        tvm.accept();
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


    fallback() external {}

    receive() external {}

    function afterSignatureCheck(TvmSlice body, TvmCell message) private inline returns (TvmSlice) {  // todo fix mock
        // Via TvmSlice methods we read header fields from the message body

        tvm.accept();
        body.decode(uint64); // The first 64 bits contain timestamp which is usually used to differentiate messages.
        uint32 expireAt = body.decode(uint32);

        // After reading message headers this function must return the rest of the body slice.
        return body;
    }

}
