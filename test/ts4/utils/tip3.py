from tonos_ts4 import ts4

from utils.utils import random_address


class TIP3Deployer:

    def __init__(self):
        self.contract = self._deploy()
        self.tip3_root = self._deploy_tip3_root()

    @staticmethod
    def _deploy() -> ts4.BaseContract:
        root_code = ts4.load_code_cell('RootTokenContract')
        wallet_code = ts4.load_code_cell('TONTokenWallet')
        return ts4.BaseContract('TestTIP3RootDeployer', {
            'root_code': root_code,
            'wallet_code': wallet_code,
        }, nickname='TIP3Deployer', override_address=random_address())

    def _deploy_tip3_root(self) -> ts4.Address:
        address = self.contract.call_method('deployTestRootTIP3')
        ts4.dispatch_messages()
        return address

    def deploy_tip3_wallet(self, owner: ts4.Address) -> ts4.Address:
        address = self.contract.call_method('deployUserTIP3Wallet', {
            'root': self.tip3_root,
            'owner': owner,
        })
        ts4.dispatch_messages()
        return address
