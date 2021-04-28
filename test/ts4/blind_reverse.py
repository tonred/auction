import unittest

import tonos_ts4.ts4 as ts4

from abstract.blind import BlindAuctionTest
from test_wallet import TestWallet
from utils.phase import Phase
from utils.utils import random_address


class BlindForwardAuctionTest(BlindAuctionTest):

    def setUp(self):
        self._setup_phase_time(Phase.WAIT)
        bid_code = ts4.load_code_cell('BlindBid')
        self.contract = ts4.BaseContract('BlindReverseAuction', {
            'fee': 1 * ts4.GRAM,
            'deposit': 10 * ts4.GRAM,
            'startTime': self.START_TIME,
            'openDuration': self.OPEN_DURATION,
            'confirmationDuration': self.CONFIRMATION_DURATION,
            'bidCode': bid_code,
        }, nickname='Auction', override_address=random_address())

    def test_confirm_bid(self):
        wallet = TestWallet()
        salt = self._generate_salt()

        self._setup_phase_time(Phase.OPEN, update=True)
        self._make_bid(wallet, value=10.1, bid_value=5, salt=salt)
        self._check_bids_count(1)  # bid really made

        self._setup_phase_time(Phase.CONFIRMATION, update=True)
        self._confirm_bid(wallet, value=1, bid_value=5, salt=salt)
        self._check_confirmed_bids_count(1)  # bid really confirmed
        self.assertEqual((100 - 1) * ts4.GRAM, wallet.balance(), 'Bid is not confirmed')

    def test_several_bids(self):
        wallet1 = TestWallet()
        salt1 = self._generate_salt()
        wallet2 = TestWallet()
        salt2 = self._generate_salt()
        wallet3 = TestWallet()
        salt3 = self._generate_salt()

        self._setup_phase_time(Phase.OPEN, update=True)
        self._make_bid(wallet1, value=10, bid_value=20, salt=salt1)  # must be returned after second bid confirmation
        self._make_bid(wallet2, value=10, bid_value=25, salt=salt2)  # winner
        self._make_bid(wallet3, value=10, bid_value=5, salt=salt3)  # must be returned immediately in confirmation
        self._check_bids_count(3)

        self._setup_phase_time(Phase.CONFIRMATION, update=True)
        self._confirm_bid(wallet1, value=11, bid_value=20, salt=salt1)  # min value = bid_value - deposit + fee
        self._confirm_bid(wallet2, value=50, bid_value=25, salt=salt2)  # or greater (all change will be returned)
        self._confirm_bid(wallet3, value=50, bid_value=5, salt=salt3)
        self._check_confirmed_bids_count(3)

        self.assertEqual((100 - 1) * ts4.GRAM, wallet1.balance(), 'Bid is not returned')
        self.assertEqual((100 - 1) * ts4.GRAM, wallet2.balance(), 'Bid is not returned')
        self.assertEqual((100 - 1) * ts4.GRAM, wallet3.balance(), 'Bid is not returned')


if __name__ == '__main__':
    unittest.main()
