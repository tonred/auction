pragma ton-solidity >= 0.39.0;

import "./abstract/EnglishAuction.sol";


contract EnglishForwardAuction is EnglishAuction {

    constructor(
        address owner,
        uint128 fee,
        uint128 startValue,
        uint128 stepValue,
        uint32 startTime,
        uint32 openDuration,
        address tip3_root
    ) public onlyRoot EnglishAuction(owner, fee, startValue, stepValue, startTime, openDuration, tip3_root) {}

    function _tokensReceivedProcess(
        uint128 tokens_amount,
        address sender_address,
        address sender_wallet,
        TvmCell /*payload*/
    ) override internal doUpdate inPhaseReturnable(Phase.OPEN, tokens_amount, sender_wallet) {
        bool accept = _checkBid(tokens_amount);
        if (!accept) {
            _transferTokens(sender_wallet, tokens_amount);
        } else {
            if (_winner.owner != address(0)) {
                _transferTokens(_winner.wallet, _winner.value);
            }
            _winner = Bid(sender_address, sender_wallet, tokens_amount);
            _bidsCount++;
            emit BidIsMade(sender_address, tokens_amount);
        }
    }

    function _checkBid(uint128 tokens_amount) private view returns (bool) {
        if (msg.value < _fee) {
            return false;
        }
        if (_winner.owner == address(0)) {
            return tokens_amount >= _startValue;
        } else {
            uint128 highest = getWinnerValue();
            return tokens_amount >= highest + _stepValue;
        }
    }

}
