# Free TON on-line Auctions

## Key features:
* Six types of auctions
* Надеюсь мы придумаем что написать)

## Deployment

Он же должен быть

## Structure

Я запихну схему наследований сюда

## Types of auctions

### English Forward
Most common type of auction. There are start value and step value.
Every bid must be greater than previous on this step value (or more).
Winner is a person with the highest bid.
Every bid must be confirmed by real crystals in a message.
When some makes bid more than your bid, you will get back you crystals values for previous bid.

In root use method `deployEnglishForwardAuction` or `deployEnglishForwardAuctionCustom` to create auction.
Use method `makeBid` in auction to submit a bid

### English Reverse

There are start value and step value. 
Every bid must be lower than previous on this step value (or more).
Winner is a person with the lowest bid.
Bids must not be confirmed by real crystals.

In root use method `deployEnglishReverseAuction` or `deployEnglishReverseAuctionCustom` to create auction.
Use method `makeBid` in auction to submit a bid

### Dutch Forward

You must set start and finish values in a constructor.
Bid price decreases from bigger (start) to smaller (finish) value.
You can get this life-time price via `getCurrentPrice` method.
More time passes - the lower price you need to bid.
Every bid must be confirmed by real crystals in a message.
Winner is a first person who make a bid.

In root use method `deployDutchForwardAuction` or `deployDutchForwardAuctionCustom` to create auction.
Use method `buy` in auction to submit a bid (and make a buy)

### Dutch Reverse

You must set start and finish values in a constructor.
Bid price increases from smaller (start) to bigger (finish) value.
You can get this life-time price via `getCurrentPrice` method.
More time passes - the bigger price you need to bid.
Bids must not be confirmed by real crystals.
Winner is a first person who make a bid.

In root use method `deployDutchReverseAuction` or `deployDutchReverseAuctionCustom` to create auction.
Use method `buy` in auction to submit a bid (and make a buy)

### Blind Forward

Firstly you must make your bid in OPEN phase.
To do this, you must generate random salt, locally encode your bid via `calcBidHash` method and then send this hash.
After then, you must wait for CONFIRMATION phase and confirm your bid.
In this step you must send your salt, bid value and crystals.
This algorithm guarantees that nobody will see your bid in OPEN phase.
In CONFIRMATION phase nobody can do new bid.
You can remove your bid in OPEN phase.
Winner is a person with the highest bid.

_Important:_ there is a deposit value that you should to submit when you make a bid.
This deposit will be returned after confirmation.
It is used to prevent spamming, when someone creates a lot of blind bid but don't confirm they.

In root use method `deployBlindForwardAuction` or `deployBlindForwardAuctionCustom` to create auction.
Use method `makeBid`, `removeBid` and `confirmBid` in auction

### Blind Reverse

Firstly you must make your bid in OPEN phase.
To do this, you must generate random salt, locally encode your bid via `calcBidHash` method and then send this hash.
After then, you must wait for CONFIRMATION phase and confirm your bid.
In this step you must send your salt and bid value.
This algorithm guarantees that nobody will see your bid in OPEN phase.
In CONFIRMATION phase nobody can do new bid.
You can remove your bid in OPEN phase.
Winner is a person with the lowest bid.

_Important:_ there is a deposit value that you should to submit when you make a bid.
This deposit will be returned after confirmation.
It is used to prevent spamming, when someone creates a lot of blind bid but don't confirm they.

In root use method `deployBlindReverseAuction` or `deployBlindReverseAuctionCustom` to create auction.
Use method `makeBid`, `removeBid` and `confirmBid` in auction

## Tests

Они есть, я рожу четь

## UI-фронт

...

## Debot

Немного скринов что он есть
