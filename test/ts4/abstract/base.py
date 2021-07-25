import typing
import unittest

from tonos_ts4 import ts4

from config import BUILD_ARTIFACTS_PATH, VERBOSE
from utils.errors import Errors
from utils.phase import Phase
from utils.test_wallet import TestWallet
from utils.tip3 import TIP3Deployer
from utils.user import User
from utils.utils import random_address


class BaseAuctionTest(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        ts4.init(BUILD_ARTIFACTS_PATH, verbose=VERBOSE)
        cls.contract: typing.Optional[ts4.BaseContract] = None
        cls.tip3_deployer: typing.Optional[TIP3Deployer] = None

    def init_contracts(self, sol_file: str, params: dict):
        self.tip3_deployer = TIP3Deployer()
        owner = self._create_user()
        params['owner'] = owner.ton_wallet.address
        params['tip3_root'] = self.tip3_deployer.tip3_root
        self.contract = ts4.BaseContract(
            sol_file,
            params,
            keypair=ts4.make_keypair(),
            nickname='Auction',
            override_address=random_address()
        )
        self.contract.call_method('setup', {
            'owner': owner.ton_wallet.address
        }, private_key=self.contract.private_key_)
        ts4.dispatch_messages()

    def _create_user(self) -> User:
        return User(self.tip3_deployer)

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
