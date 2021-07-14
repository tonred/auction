import random

import tonos_ts4.ts4 as ts4

from abstract.base import BaseAuctionTest
from test_wallet import TestWallet
from utils.errors import Errors
from utils.phase import Phase


class BlindAuctionTest(BaseAuctionTest):
    START_TIME = 10
    OPEN_DURATION = 40
    CONFIRMATION_DURATION = 10

    def test_open_time(self):
        open_time = self.contract.call_getter('getOpenTime')
        open_time_expected = {
            'startTime': self.START_TIME,
            'finishTime': self.START_TIME + self.OPEN_DURATION,
        }
        self.assertEqual(open_time_expected, open_time, 'Open time is wrong')

    def test_confirmation_time(self):
        confirmation_time = self.contract.call_getter('getConfirmationTime')
        confirmation_time_expected = {
            'startTime': self.START_TIME + self.OPEN_DURATION,
            'finishTime': self.START_TIME + self.OPEN_DURATION + self.CONFIRMATION_DURATION,
        }
        self.assertEqual(confirmation_time_expected, confirmation_time, 'Confirmation time is wrong')

    def test_phases(self):
        self.assertEqual(Phase.WAIT, self._phase(), 'Phase must be WAIT')

        self._setup_phase_time(Phase.OPEN, update=True)
        self.assertEqual(Phase.OPEN, self._phase(), 'Phase must be OPEN')

        self._setup_phase_time(Phase.CONFIRMATION, update=True)
        self.assertEqual(Phase.CONFIRMATION, self._phase(), 'Phase must be CONFIRMATION')

        self._setup_phase_time(Phase.CLOSE, update=True)
        self.assertEqual(Phase.CLOSE, self._phase(), 'Phase must be CLOSE')

    def test_bid_in_wait_phase(self):
        self._wrong_phase_bid_test()

    def test_bid_in_confirmation_phase(self):
        self._setup_phase_time(Phase.CONFIRMATION, update=True)
        self._wrong_phase_bid_test()

    def test_bid_in_close_phase(self):
        self._setup_phase_time(Phase.CLOSE, update=True)
        self._wrong_phase_bid_test()

    def test_bid_on_confirmation(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        self._setup_phase_time(Phase.CONFIRMATION, update=False)
        self._wrong_phase_bid_test()

    def test_bid_in_open_phase(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        wallet = TestWallet()
        salt = self._generate_salt()
        self._make_bid(wallet, value=10, bid_value=5, salt=salt)
        self._check_bids_count(1)
        self.assertEqual((100 - 10) * ts4.GRAM, wallet.balance, 'Bid is not made')

    def test_remove_bid(self):
        wallet = TestWallet()
        salt = self._generate_salt()

        self._setup_phase_time(Phase.OPEN, update=True)
        self._make_bid(wallet, value=10.1, bid_value=5, salt=salt)
        self._check_bids_count(1)  # bid really made

        self._remove_bid(wallet, value=1, bid_value=5, salt=salt)
        self._check_bids_count(0)  # bid really removed
        self.assertEqual((100 - 1) * ts4.GRAM, wallet.balance, 'Bid is not removed')

    def test_low_bid_value(self):
        self._setup_phase_time(Phase.OPEN, update=True)
        wallet = TestWallet()
        salt = self._generate_salt()
        self._make_bid(wallet, value=9, bid_value=5, salt=salt, expect_ec=Errors.VALUE_LESS_THAN_DEPOSIT)
        self._check_bids_count(0)
        self.assertEqual(100 * ts4.GRAM, wallet.balance, 'Bid is not made')

    def _wrong_phase_bid_test(self):
        wallet = TestWallet()
        salt = self._generate_salt()
        self._make_bid(wallet, value=10, bid_value=5, salt=salt, expect_ec=Errors.WRONG_PHASE)
        self._check_bids_count(0)
        self._check_confirmed_bids_count(0)
        self.assertEqual(100 * ts4.GRAM, wallet.balance, 'Bid is not returned')

    def _setup_phase_time(self, phase: Phase, update: bool = False):
        if phase == Phase.WAIT:
            ts4.core.set_now(self.START_TIME - 1)
        if phase == Phase.OPEN:
            ts4.core.set_now(self.START_TIME + self.OPEN_DURATION // 2)
        if phase == Phase.CONFIRMATION:
            ts4.core.set_now(self.START_TIME + self.OPEN_DURATION + self.CONFIRMATION_DURATION // 2)
        if phase == phase.CLOSE:
            ts4.core.set_now(self.START_TIME + self.OPEN_DURATION + self.CONFIRMATION_DURATION + 1)

        if update:
            self._update()

    def _check_bids_count(self, expected: int):
        actual = self.contract.call_getter('getBidsCount')
        self.assertEqual(expected, actual, 'Wrong bids count')

    def _check_confirmed_bids_count(self, expected: int):
        actual = self.contract.call_getter('getConfirmedBidsCount')
        self.assertEqual(expected, actual, 'Wrong confirmed bids count')

    def _make_bid(self, wallet: TestWallet, value: float, bid_value: float, salt: int, expect_ec: int = 0):
        destination = self.contract.address
        bid_value = int(bid_value * ts4.GRAM)
        hash_ = self._calc_hash(bid_value, salt)
        value = int(value * ts4.GRAM)
        wallet.blind_make_bid(destination, value, hash_, expect_ec=expect_ec)

    def _remove_bid(self, wallet: TestWallet, value: float, bid_value: float, salt: int, expect_ec: int = 0):
        destination = self.contract.address
        bid_value = int(bid_value * ts4.GRAM)
        hash_ = self._calc_hash(bid_value, salt)
        value = int(value * ts4.GRAM)
        wallet.blind_remove_bid(destination, value, hash_, expect_ec=expect_ec)

    def _confirm_bid(self, wallet: TestWallet, value: float, bid_value: float, salt: int, expect_ec: int = 0):
        destination = self.contract.address
        bid_value = int(bid_value * ts4.GRAM)
        value = int(value * ts4.GRAM)
        wallet.blind_confirm_bid(destination, value, bid_value, salt, expect_ec=expect_ec)

    @staticmethod
    def _generate_salt() -> int:
        return random.randint(0, 2 ** 256 - 1)

    def _calc_hash(self, bid_value: int, salt: int) -> int:
        return self.contract.call_getter('calcBidHash', {
            'value': bid_value,
            'salt': salt,
        })
