import json
import os

from tonclient.types import CallSet
from tonos_ts4 import ts4

from config import BUILD_ARTIFACTS_PATH
from utils.test_wallet import TestWallet
from utils.tip3 import TIP3Deployer


class User:

    def __init__(self, tip3_deployer: TIP3Deployer):
        self.ton_wallet = TestWallet()
        self.tip3_wallet = self._create_tip3_wallet(self.ton_wallet.address, tip3_deployer)

    @staticmethod
    def _create_tip3_wallet(owner: ts4.Address, tip3_deployer: TIP3Deployer) -> ts4.BaseContract:
        address = tip3_deployer.deploy_tip3_wallet(owner)
        return ts4.BaseContract('TONTokenWallet', {}, nickname='TONTokenWallet', address=address)

    def transfer_tip3(self, destination: ts4.Address, value: int, expect_ec: int = 0):
        call_set = CallSet('transfer', input={
            'to': destination.str(),
            'tokens': value,
            'grams': 0,
            'send_gas_to': self.ton_wallet.address.str(),
            'notify_receiver': True,
            'payload': ts4.EMPTY_CELL,
        })
        skip_before_expect = 0 if expect_ec == 0 else 2  # skip 2 messages - send_transaction and callback
        abi = self._load_tip3_wallet_abi()
        self.ton_wallet.send_call_set(
            self.tip3_wallet.address,
            1 * ts4.GRAM,
            call_set=call_set,
            abi=abi,
            expect_ec=expect_ec,
            skip_before_expect=skip_before_expect
        )

    @staticmethod
    def _load_tip3_wallet_abi() -> dict:
        path = os.path.join(BUILD_ARTIFACTS_PATH, 'TONTokenWallet.abi.json')
        with open(path, 'r') as file:
            content = file.read()
        return json.loads(content)

    @property
    def tip3_balance(self) -> int:
        return self.tip3_wallet.call_getter('balance', {'_answer_id': 0})
