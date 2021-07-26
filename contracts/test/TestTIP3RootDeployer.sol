pragma ton-solidity >=0.39.0;

import "../tip3/RootTokenContract.sol";


contract TestTIP3Deployer  {

    TvmCell _root_code;
    TvmCell _wallet_code;


    constructor(TvmCell root_code, TvmCell wallet_code) public {
        tvm.accept();
        _root_code = root_code;
        _wallet_code = wallet_code;
    }


    function deployTestRootTIP3() public view returns (address) {
        tvm.accept();
        TvmCell stateInit = tvm.buildStateInit({
            contr: RootTokenContract,
            varInit: {
                name: "TestToken",
                symbol: "TEST",
                decimals: 9,
                wallet_code: _wallet_code
            },
            code: _root_code
        });
        address test_root = new RootTokenContract{
            stateInit: stateInit,
            value: 10 ton
        }(0, address(this));
        return test_root;
    }

    function deployUserTIP3Wallet(address root, address owner) public view returns (address) {
        tvm.accept();
        TvmCell stateInit = tvm.buildStateInit({
            contr: TONTokenWallet,
            varInit: {
                root_address: root,
                code: _wallet_code,
                wallet_public_key: 0,
                owner_address: owner
            },
            code: _wallet_code
        });
        address tip_wallet = new TONTokenWallet{
            stateInit: stateInit,
            value: 10 ton
        }();
        RootTokenContract(root).mint(100, tip_wallet);
        return tip_wallet;
    }

}
