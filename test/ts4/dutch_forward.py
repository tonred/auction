from tonos_ts4 import ts4

from abstract.dutch import DutchAuctionTest
from utils.phase import Phase


class DutchForwardAuctionTest(DutchAuctionTest):

    def setUp(self):
        ts4.reset_all()
        self._setup_phase_time(Phase.WAIT)
        self.init_contracts('DutchForwardAuction', {
            'fee': 1 * ts4.GRAM,
            'startValue': 10,
            'finishValue': 2,
            'startTime': self.START_TIME,
            'openDuration': self.OPEN_DURATION,
        })

    def test_current_price(self):
        # 10 [0%] -> 8 [25%] -> 6 [50%] -> 4 [75%] -> 2 [100%]
        ts4.core.set_now(self.START_TIME)
        self.assertEqual(10, self._current_price(), 'Wrong price calculation')
        ts4.core.set_now(int(self.START_TIME + 0.25 * self.OPEN_DURATION))
        self.assertEqual(8, self._current_price(), 'Wrong price calculation')
        ts4.core.set_now(int(self.START_TIME + 0.5 * self.OPEN_DURATION))
        self.assertEqual(6, self._current_price(), 'Wrong price calculation')
        ts4.core.set_now(int(self.START_TIME + 0.75 * self.OPEN_DURATION))
        self.assertEqual(4, self._current_price(), 'Wrong price calculation')
        ts4.core.set_now(self.START_TIME + self.OPEN_DURATION)
        self.assertEqual(2, self._current_price(), 'Wrong price calculation')

    def test_bid_in_open_phase(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        user = self._create_user()
        self._send_tip3(user, value=9)
        self.assertEqual(Phase.CLOSE, self._phase(), 'Auction is not finished')
        self.assertEqual(100 - 9, user.tip3_balance, 'Bid is not made')

    def test_low_bids_start(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        user = self._create_user()
        self._send_tip3(user, value=1)
        self.assertEqual(100, user.tip3_balance, 'Bid is not returned')

    def test_low_bids_step(self):
        ts4.core.set_now(int(self.START_TIME + 0.5 * self.OPEN_DURATION))
        user = self._create_user()
        self._send_tip3(user, value=5)
        self.assertEqual(100, user.tip3_balance, 'Bid is not returned')
