import json
import unittest

from tonclient.types import CallSet
from tonos_ts4 import ts4

from config import BUILD_ARTIFACTS_PATH, VERBOSE
from test_wallet import TestWallet
from utils.utils import random_address


class WorkflowTest(unittest.TestCase):
    AUCTION_NAMES = (
        'EnglishForward', 'EnglishReverse',
        'DutchForward', 'DutchReverse',
        'BlindForward', 'BlindReverse'
    )

    def setUp(self):
        ts4.init(BUILD_ARTIFACTS_PATH, verbose=VERBOSE)
        ts4.core.set_now(0)
        self.auction_root = ts4.BaseContract('TestAuctionRoot', {
            'deployValue': 2 * ts4.GRAM,
            'defaultFeeValue': 1 * ts4.GRAM,
            'defaultDepositValue': 10 * ts4.GRAM,
        }, nickname='AuctionRoot', override_address=random_address())

        for auction_name in self.AUCTION_NAMES:
            code = ts4.load_code_cell(f'{auction_name}Auction')
            self.auction_root.call_method(f'setCode{auction_name}Auction', {
                f'code': code
            })
            ts4.dispatch_messages()
        code_blind_bid = ts4.load_code_cell(f'BlindBid')
        self.auction_root.call_method(f'setCodeBlindBid', {
            f'code': code_blind_bid
        })
        ts4.dispatch_messages()
        self.auction_root.call_method('finishInit', {})
        ts4.dispatch_messages()

    def test_workflow(self):
        # Create organizer and participant contracts
        organizer = ts4.BaseContract('TestUsage', {
            'auctionRoot': self.auction_root.address,
        }, nickname='User', override_address=random_address())
        participant = TestWallet()

        # Organizer creates auction
        organizer.call_method('createAuction')
        ts4.dispatch_messages()
        auction_contract_address = organizer.call_getter('getAuctionContract')
        ts4.dispatch_messages()

        # Start auction
        ts4.core.set_now(30)
        participant.update(auction_contract_address, 1 * ts4.GRAM)

        # Participant makes bid
        abi = self._load_abi()
        bid_value = 9 * ts4.GRAM
        value = 10 * ts4.GRAM
        call_set = CallSet('makeBid', input={'value': bid_value})
        participant.send_call_set(auction_contract_address, value, call_set=call_set, abi=abi)

        # Finish auction
        ts4.core.set_now(100)
        participant.update(auction_contract_address, 1 * ts4.GRAM)
        ts4.dispatch_messages()

        # Organizer can get winner
        winner_address = organizer.call_getter('getWinner')
        self.assertEqual(winner_address, participant.address)
        print(f'Winner: {winner_address}')

    @staticmethod
    def _load_abi() -> dict:
        with open('../../build-artifacts/EnglishForwardAuction.abi.json', 'r') as file:
            content = file.read()
        return json.loads(content)
