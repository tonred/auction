from abc import ABC

from abstract.common import CommonAuctionTest
from utils.phase import Phase


class DutchAuctionTest(ABC, CommonAuctionTest):

    def test_bid_in_wait_phase(self):
        user = self._create_user()
        self._send_tip3(user, value=3)
        self.assertEqual(100, user.tip3_balance, 'Bid is not returned')

    def test_bid_in_close_phase(self):
        user = self._create_user()
        self._setup_phase_time(Phase.CLOSE, update=True)
        self._send_tip3(user, value=5)
        self.assertEqual(100, user.tip3_balance, 'Bid is not returned')

    def test_bid_on_close(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        self._setup_phase_time(Phase.CLOSE, update=False)
        user = self._create_user()
        self._send_tip3(user, value=5)
        self.assertEqual(100, user.tip3_balance, 'Bid is not returned')

    def _current_price(self) -> int:
        return self.contract.call_getter('getCurrentPrice')
