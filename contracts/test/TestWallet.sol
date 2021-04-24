pragma ton-solidity >=0.39.0;


contract TesWallet {
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


    fallback() external {}

    receive() external {}
}
