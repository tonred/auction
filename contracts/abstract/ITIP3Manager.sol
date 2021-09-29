pragma ton-solidity >= 0.39.0;

import "../tip3/interfaces/IRootTokenContract.sol";
import "../tip3/interfaces/ITONTokenWallet.sol";
import "../tip3/interfaces/ITokensReceivedCallback.sol";
import "../tip3/interfaces/IExpectedWalletAddressCallback.sol";
import "../tip3/interfaces/ITokenWalletDeployedCallback.sol";
import "../Lib.sol";

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


abstract contract ITIP3Manager is ITokensReceivedCallback, IExpectedWalletAddressCallback, ITokenWalletDeployedCallback {
    uint128 constant DEPLOY_EMPTY_WALLET_VALUE = 0.2 ton;
    uint128 constant DEPLOY_EMPTY_WALLET_GRAMS = 0.1 ton;
    uint128 constant SEND_EXPECTED_WALLET_VALUE = 0.1 ton;
    uint128 constant INITIAL_BALANCE = 1 ton;
    uint128 constant TRANSFER_VALUE = 0.2 ton;
    uint8 constant SENDER_PAYS_FEES = 1;
    uint8 constant REMAINING_GAS = 64;

    address public _tip3_root;
    address public _tip3_wallet;


    constructor(address owner, address tip3_root) public {
        tvm.accept();
        _tip3_root = tip3_root;
        ITIP3Manager(address(this)).setup{value: 0, flag: 128, bounce: false}(owner);
    }

    function setup(address owner) public view {
        require(msg.pubkey() == tvm.pubkey() || msg.sender == address(this), Errors.IS_NOT_TIP3_OWNER);
        tvm.accept();
        IRootTokenContract(_tip3_root)
            .deployEmptyWallet {
                value: DEPLOY_EMPTY_WALLET_VALUE,
                flag: SENDER_PAYS_FEES
            }(
                DEPLOY_EMPTY_WALLET_GRAMS,  // deploy_grams
                0,                          // wallet_public_key
                address(this),              // owner_address
                owner                       // gas_back_address
            );
        IRootTokenContract(_tip3_root)
            .sendExpectedWalletAddress {
                value: SEND_EXPECTED_WALLET_VALUE,
                flag: SENDER_PAYS_FEES
            }(
                0,              // wallet_public_key_
                address(this),  // owner_address_
                address(this)   // to
            );
    }

    function getTIP3Root() public view returns (address) {
        return _tip3_root;
    }

    function getTIP3Wallet() public view returns (address) {
        return _tip3_wallet;
    }

    // callback for IRootTokenContract(...).sendExpectedWalletAddress
    function expectedWalletAddressCallback(
        address wallet,
        uint256 wallet_public_key,
        address owner_address
    ) override public {
        require(msg.sender == _tip3_root, Errors.IS_NOT_TIP3_ROOT);
        require(wallet_public_key == 0, Errors.IS_NOT_TIP3_OWNER);
        require(owner_address == address(this), Errors.IS_NOT_TIP3_OWNER);
        tvm.accept();

        _tip3_wallet = wallet;
        ITONTokenWallet(_tip3_wallet)
            .setReceiveCallback {
                value: 0,
                flag: REMAINING_GAS
            }(
                address(this),  // receive_callback_
                false           // allow_non_notifiable_
            );
    }

    function notifyWalletDeployed(address /*root*/) override public {
//        tvm.log("notifyWalletDeployed");
    }

    function tokensReceivedCallback(
        address token_wallet,
        address /*token_root*/,
        uint128 tokens_amount,
        uint256 sender_public_key,
        address sender_address,
        address sender_wallet,
        address /*original_gas_to*/,
        uint128 /*updated_balance*/,
        TvmCell payload
    ) override public {
        require(msg.sender == _tip3_wallet, Errors.IS_NOT_TIP3_OWNER);
        require(sender_public_key == 0, Errors.IS_NOT_TIP3_OWNER);
        require(token_wallet == _tip3_wallet, Errors.IS_NOT_TIP3_OWNER);
        tvm.accept();

        tvm.rawReserve(INITIAL_BALANCE, 2);
        _tokensReceivedProcess(tokens_amount, sender_address, sender_wallet, payload);
        sender_address.transfer({value: 0, flag: REMAINING_GAS, bounce: false});
    }

    function _tokensReceivedProcess(
        uint128 tokens_amount,
        address sender_address,
        address sender_wallet,
        TvmCell payload
    ) virtual internal;

    function _transferTokens(address destination, uint128 value) internal view {
        TvmCell empty;
        ITONTokenWallet(_tip3_wallet)
            .transfer {
                value: TRANSFER_VALUE,
                flag: 1
            }(
                destination,   // to
                value,         // tokens
                0,             // grams,
                _tip3_wallet,  // send_gas_to,
                true,          // notify_receiver
                empty          // payload
            );
    }

}
