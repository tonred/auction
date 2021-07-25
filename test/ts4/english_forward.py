from tonos_ts4 import ts4

from abstract.english import EnglishAuctionTest
from utils.phase import Phase


class EnglishForwardAuctionTest(EnglishAuctionTest):

    def setUp(self):
        ts4.reset_all()
        self._setup_phase_time(Phase.WAIT)
        self.init_contracts('EnglishForwardAuction', {
            'fee': 1 * ts4.GRAM,
            'startValue': 3,
            'stepValue': 2,
            'startTime': self.START_TIME,
            'openDuration': self.OPEN_DURATION,
        })

    def test_bid_in_open_phase(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        user = self._create_user()
        self._make_bid(user, value=3)
        self._check_bids_count(1)
        self.assertEqual(100 - 3, user.tip3_balance, 'Bid is not made')

    def test_increasing_bids(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        user_1 = self._create_user()
        user_2 = self._create_user()
        user_3 = self._create_user()

        self._make_bid(user_1, value=3)
        self._make_bid(user_2, value=5)
        self._make_bid(user_3, value=12)
        self._check_bids_count(3)

        self.assertEqual(12, self.contract.call_getter('getWinnerValue'), 'Bid is not made')
        self.assertEqual(100, user_1.tip3_balance, 'Bid is not returned')
        self.assertEqual(100, user_2.tip3_balance, 'Bid is not returned')
        self.assertEqual(100 - 12, user_3.tip3_balance, 'Bid is not made')

    def test_low_bids_start(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        user = self._create_user()
        self._make_bid(user, value=1)  # too low bid
        self._check_bids_count(0)
        self.assertEqual(100, user.tip3_balance, 'Bid is not returned')

    def test_low_bids_step(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        user = self._create_user()
        self._make_bid(user, value=4)  # good bid
        self._make_bid(user, value=5)  # too low step
        self._check_bids_count(1)
        self.assertEqual(100 - 4, user.tip3_balance, 'Bid is not returned')

    def test_bid_return(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        user_1 = self._create_user()
        user_2 = self._create_user()

        self._make_bid(user_1, value=3)  # first bid
        self.assertEqual(100 - 3, user_1.tip3_balance, 'Bid is not made')

        self._make_bid(user_2, value=5)  # second bid
        self.assertEqual(100 - 5, user_2.tip3_balance, 'Bid is not made')
        self.assertEqual(100, user_1.tip3_balance, 'Bid is not returned')
