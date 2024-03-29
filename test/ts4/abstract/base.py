import typing
import unittest

from tonos_ts4 import ts4

from config import BUILD_ARTIFACTS_PATH, VERBOSE
from test_wallet import TestWallet
from utils.errors import Errors
from utils.phase import Phase


class BaseAuctionTest(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        ts4.init(BUILD_ARTIFACTS_PATH, verbose=VERBOSE)
        cls.contract: typing.Optional[ts4.BaseContract] = None

    def test_id(self):
        _id = self.contract.call_getter('getId')
        self.assertEqual(0, _id)

    def test_owner(self):
        owner = self.contract.call_getter('getOwner')
        self.assertIsNotNone(owner)

    def test_finish_outside(self):
        self.contract.call_getter('finish', expect_ec=Errors.IS_NOT_SELF)

    def _update(self):
        wallet = TestWallet()
        wallet.update(self.contract.address, 1 * ts4.GRAM)

    def _phase(self) -> Phase:
        return Phase(self.contract.call_getter('getPhase'))
