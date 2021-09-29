pragma ton-solidity >= 0.39.0;

import "./abstract/DutchAuction.sol";


contract DutchForwardAuction is DutchAuction {

    constructor(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 finishValue,
        uint32 startTime,
        uint32 openDuration,
        address tip3_root
    ) public onlyRoot DutchAuction(owner, fee, startValue, finishValue, startTime, openDuration, tip3_root) {
        require(startValue > finishValue, Errors.START_LESS_THAN_FINISH);
    }

    function _tokensReceivedProcess(
        uint128 tokens_amount,
        address sender_address,
        address sender_wallet,
        TvmCell /*payload*/
    ) override internal doUpdate inPhaseReturnable(Phase.OPEN, tokens_amount, sender_wallet) {
        bool accept = _canBuy(tokens_amount);
        if (!accept) {
            _transferTokens(sender_wallet, tokens_amount);
        } else {
            _winner = Bid(sender_address, sender_wallet, tokens_amount);
            emit BidIsMade(sender_address, tokens_amount);
            _sendFinish();
        }
    }

    function _canBuy(uint128 tokens_amount) private view returns (bool) {
        if (msg.value < _fee) {
            return false;
        }
        return tokens_amount >= getCurrentPrice();
    }

}
