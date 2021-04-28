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
    @value Must be enough for all gas used in this operation
    */
    function confirmBid(uint128 value, uint256 salt) override public view doUpdate inPhase(Phase.CONFIRMATION) {
        uint256 hash = calcBidHash(value, salt);
        address bidAddress = _calcBidAddress(msg.sender, hash);
        BlindBid(bidAddress).confirm{
            value: 0,
            callback: confirmBidCallback
        }(value, msg.value);
        msg.sender.transfer({value : 0, flag : SEND_ALL_GAS, bounce: false});
    }

    // last argument (msgValue) is unused in reverse auction
    function confirmBidCallback(address owner, uint256 hash, uint128 value, uint128) public {
        _checkIsBidCallback(owner, hash);
        _bidsCount++;
        owner.transfer(_deposit - _fee);
        Bid bid = Bid(owner, value);
        _updateResults(bid);
    }

    function _updateResults(Bid bid) override internal {
        if (_winner.owner == address(0)) {
            _winner = bid;
        } else if (bid.value < _winner.value) {
            _winner = bid;
        }
    }

}
