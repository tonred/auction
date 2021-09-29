pragma ton-solidity >= 0.39.0;

import "./abstract/BlindAuction.sol";


contract BlindForwardAuction is BlindAuction {

    constructor(
        address owner,
        uint128 fee,
        uint128 deposit,
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration,
        TvmCell bidCode,
        address tip3_root
    ) public onlyRoot BlindAuction(owner, fee, deposit, startTime, openDuration, confirmationDuration, bidCode, tip3_root) {}


    /*
    @param value Real value of bid
    @param salt  Random value that was used to calculate hash in `calcBidHash` method
    */
    function buildConfirmPayload(uint128 value, uint256 salt) public pure returns (TvmCell) {
        TvmBuilder builder;
        builder.store(value, salt);
        return builder.toCell();
    }

    /*
    @param tokens_amount Real value of bid, must be equal to `value` part in `payload`
    @param payload       TvmCell that built in `buildConfirmPayload` function
    */
    function _tokensReceivedProcess(
        uint128 tokens_amount,
        address sender_address,
        address sender_wallet,
        TvmCell payload
    ) override internal doUpdate inPhaseReturnable(Phase.CONFIRMATION, tokens_amount, sender_wallet) {
        (uint128 value, uint256 salt) = payload.toSlice().decodeFunctionParams(buildConfirmPayload);
        if (tokens_amount != value) {
            _transferTokens(sender_wallet, tokens_amount);
            return;
        }
        uint256 hash = calcBidHash(value, salt);
        address bidAddress = _calcBidAddress(sender_address, hash);
        BlindBid(bidAddress).confirm{
            value: 0,
            flag: SEND_ALL_GAS,
            callback: confirmBidCallback
        }(value, msg.value, sender_wallet);
    }

    function confirmBidCallback(address owner, uint256 hash, uint128 value, uint128 msgValue, address wallet) public {
        _checkIsBidCallback(owner, hash);
        _bidsCount++;
        uint128 leaveValue = msgValue + _deposit - _fee;
        if (leaveValue > 0) {
            owner.transfer({value: leaveValue, flag: 1, bounce: false});
        }
        Bid bid = Bid(owner, wallet, value);
        _updateResults(bid);
    }

    function _updateResults(Bid bid) override internal {
        if (_winner.owner == address(0)) {
            _winner = bid;
        } else {
            if (bid.value > _winner.value) {
                _returnBid(_winner);
                _winner = bid;
            } else {
                _returnBid(bid);
            }
        }
    }

    function _returnBid(Bid bid) private view {
        _transferTokens(bid.wallet, bid.value);
    }

}
