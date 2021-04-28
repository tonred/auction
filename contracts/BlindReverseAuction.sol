pragma ton-solidity >= 0.39.0;

import "./abstract/BlindAuction.sol";


contract BlindReverseAuction is BlindAuction {

    constructor(
        uint128 fee,
        uint128 deposit,
        uint32 startTime,
        uint32 openDuration,
        uint32 confirmationDuration,
        TvmCell bidCode
    ) public onlyRoot BlindAuction(fee, deposit, startTime, openDuration, confirmationDuration, bidCode) {}

    /*
    @param value Real value of bid
    @param salt  Random value that was used to calculate hash in `calcBidHash` method
    @value You must send all tokens of your bid, can be calculated as (bid_value + fee - deposit)
    */
    function confirmBid(uint128 value, uint256 salt) override public view doUpdate inPhase(Phase.CONFIRMATION) {
        require(msg.value + _deposit >= value + _fee, Errors.NOT_ENOUGH_TOKENS);
        uint256 hash = calcBidHash(value, salt);
        address bidAddress = _calcBidAddress(msg.sender, hash);
        BlindBid(bidAddress).confirm{
            value: 0,
            flag: SEND_ALL_GAS,
            callback: confirmBidCallback
        }(value, msg.value);
    }

    function confirmBidCallback(address owner, uint256 hash, uint128 value, uint128 msgValue) public {
        _checkIsBidCallback(owner, hash);
        _bidsCount++;
        uint128 leaveValue = msgValue + _deposit - value - _fee;
        if (leaveValue > 0) {
            owner.transfer(leaveValue);
        }
        if (value > _winner.value) {
            _winner = Bid(owner, value);
        }
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

    function _returnBid(Bid bid) private pure {
        bid.owner.transfer(bid.value);
    }

}
