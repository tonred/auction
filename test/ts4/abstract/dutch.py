from abc import ABC, abstractmethod

from tonclient.types import CallSet
from tonos_ts4 import ts4

from abstract.common import CommonAuctionTest
from utils.errors import Errors
from utils.phase import Phase
from utils.test_wallet import TestWallet


class DutchAuctionTest(ABC, CommonAuctionTest):

    def test_bid_in_wait_phase(self):
        wallet = TestWallet()
        self._buy(wallet, bid_value=5, expect_ec=Errors.WRONG_PHASE)

    def test_bid_in_close_phase(self):
        wallet = TestWallet()
        self._setup_phase_time(Phase.CLOSE, update=True)
        self._buy(wallet, bid_value=5, expect_ec=Errors.WRONG_PHASE)

    def test_bid_on_close(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        self._setup_phase_time(Phase.CLOSE, update=False)
        wallet = TestWallet()
        self._buy(wallet, bid_value=5, expect_ec=Errors.WRONG_PHASE)
        self.assertEqual(100 * ts4.GRAM, wallet.balance, 'Bid is not returned')

    def _current_price(self) -> int:
        return self.contract.call_getter('getCurrentPrice')

    @abstractmethod
    def _buy(self, wallet: TestWallet, bid_value: float, expect_ec: int = 0):
        pass

    def _call_buy(
            self,
            wallet: TestWallet,
            destination: ts4.Address,
            value: int,
            bid_value: int,
            expect_ec: int = 0
    ):
        call_set = CallSet('buy', input={'value': bid_value})
        wallet.send_call_set(destination, value, call_set=call_set, abi=self.contract.abi_, expect_ec=expect_ec)
