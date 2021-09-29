pragma ton-solidity >=0.39.0;

pragma AbiHeader time;
pragma AbiHeader expire;

import "../abstract/BaseAuction.sol";


contract TestWallet is ITokenWalletDeployedCallback {

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

    function notifyWalletDeployed(address /*root*/) override public {
        msg.sender.transfer({value: 0, flag: 64, bounce: false});
    }


    fallback() external {}

    receive() external {}

    function afterSignatureCheck(TvmSlice body, TvmCell /*message*/) private pure inline returns (TvmSlice) {  // todo fix mock
        tvm.accept();

        // Via TvmSlice methods we read header fields from the message body
        body.decode(uint64); // The first 64 bits contain `timestamp` which is usually used to differentiate messages.
        body.decode(uint32);  // The next 32 bits contain `expireAt` timestamp

        // After reading message headers this function must return the rest of the body slice.
        return body;
    }

}
