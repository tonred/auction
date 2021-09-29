from tonos_ts4 import ts4

from abstract.blind import BlindAuctionTest
from utils.phase import Phase
from utils.utils import random_address


class BlindForwardAuctionTest(BlindAuctionTest):

    def setUp(self):
        ts4.reset_all()
        self._setup_phase_time(Phase.WAIT)
        bid_code = ts4.load_code_cell('BlindBid')
        self.init_contracts('BlindForwardAuction', {
            'owner': random_address(),
            'fee': 1 * ts4.GRAM,
            'deposit': 10 * ts4.GRAM,
            'startTime': self.START_TIME,
            'openDuration': self.OPEN_DURATION,
            'confirmationDuration': self.CONFIRMATION_DURATION,
            'bidCode': bid_code,
        })

    def test_confirm_bid(self):
        user = self._create_user()
        salt = self._generate_salt()

        self._setup_phase_time(Phase.OPEN, update=True)
        self._make_bid(user, value=10.1, bid_value=5, salt=salt)
        self._check_bids_count(1)  # bid really made

        self._setup_phase_time(Phase.CONFIRMATION, update=True)
        self._confirm_bid(user, bid_value=5, salt=salt)
        self._check_confirmed_bids_count(1)  # bid really confirmed
        self.assertEqual(100 - 5, user.tip3_balance, 'Bid is not confirmed')
        self.assertEqual((100 - 1) * ts4.GRAM, user.ton_balance, 'Bid is not confirmed')

    def test_several_bids(self):
        user1 = self._create_user()
        salt1 = self._generate_salt()
        user2 = self._create_user()
        salt2 = self._generate_salt()
        user3 = self._create_user()
        salt3 = self._generate_salt()

        self._setup_phase_time(Phase.OPEN, update=True)
        self._make_bid(user1, value=10, bid_value=20, salt=salt1)  # must be returned after second bid confirmation
        self._make_bid(user2, value=10, bid_value=25, salt=salt2)  # winner
        self._make_bid(user3, value=10, bid_value=5, salt=salt3)  # must be returned immediately in confirmation
        self._check_bids_count(3)

        self._setup_phase_time(Phase.CONFIRMATION, update=True)
        self._confirm_bid(user1, bid_value=20, salt=salt1)  # min value = bid_value - deposit + fee
        self._confirm_bid(user2, bid_value=25, salt=salt2)  # or greater (all change will be returned)
        self._confirm_bid(user3, bid_value=5, salt=salt3)
        self._check_confirmed_bids_count(3)

        self.assertEqual(100, user1.tip3_balance, 'Bid is not returned')
        self.assertEqual((100 - 1) * ts4.GRAM, user1.ton_balance, 'Bid is not returned')
        self.assertEqual(100 - 25, user2.tip3_balance, 'Bid is not confirmed')
        self.assertEqual((100 - 1) * ts4.GRAM, user2.ton_balance, 'Bid is not confirmed')
        self.assertEqual(100, user3.tip3_balance, 'Bid is not returned')
        self.assertEqual((100 - 1) * ts4.GRAM, user3.ton_balance, 'Bid is not returned')

    def test_low_confirmation_value(self):
        user = self._create_user()
        salt = self._generate_salt()

        self._setup_phase_time(Phase.OPEN, update=True)
        self._make_bid(user, value=10, bid_value=20, salt=salt)
        self._check_bids_count(1)

        self._setup_phase_time(Phase.CONFIRMATION, update=True)
        # incorrect bid - real bid `value` (19) less that `value` in payload (20)
        payload = self.contract.call_getter('buildConfirmPayload', {
            'value': 20,
            'salt': salt,
        })
        self._send_tip3(user, value=19, payload=payload.raw_)
        self._check_confirmed_bids_count(0)

        self.assertEqual(100, user.tip3_balance, 'Confirmation bid is not returned')
        # (100 - 10) - deposit is not returned because bid is not confirmed
        self.assertEqual((100 - 10) * ts4.GRAM, user.ton_balance, 'Confirmation bid is not returned')
