from abc import ABC

from tonclient.types import CallSet
from tonos_ts4 import ts4

from abstract.common import CommonAuctionTest
from utils.phase import Phase
from utils.test_wallet import TestWallet


class EnglishAuctionTest(ABC, CommonAuctionTest):

    def test_bid_in_wait_phase(self):
        user = self._create_user()
        self._make_bid(user, value=3)
        self._check_bids_count(0)
        self.assertEqual(100, user.tip3_balance, 'Bid is not returned')

    def test_bid_in_close_phase(self):
        user = self._create_user()
        self._setup_phase_time(Phase.CLOSE, update=True)
        self._make_bid(user, value=5)
        self._check_bids_count(0)
        self.assertEqual(100, user.tip3_balance, 'Bid is not returned')

    def test_bid_on_close(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        self._setup_phase_time(Phase.CLOSE, update=False)
        user = self._create_user()
        self._make_bid(user, value=5)
        self._check_bids_count(0)
        self.assertEqual(100, user.tip3_balance, 'Bid is not returned')

    def _check_bids_count(self, expected: int):
        actual = self.contract.call_getter('getBidsCount')
        self.assertEqual(expected, actual, 'Wrong bids count')

    # @abstractmethod
    # def _make_bid(self, wallet: TestWallet, bid_value: float, expect_ec: int = 0):
    #     pass

    def _call_make_bid(
            self,
            wallet: TestWallet,
            destination: ts4.Address,
            value: int,
            bid_value: int,
            expect_ec: int = 0,
    ):
        call_set = CallSet('makeBid', input={'value': bid_value})
        wallet.send_call_set(destination, value, call_set=call_set, abi=self.contract.abi_, expect_ec=expect_ec)
