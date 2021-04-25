from tonos_ts4 import ts4

from utils.utils import random_address


class TestWallet(ts4.BaseContract):
    def __init__(self):
        super().__init__('TestWallet', {}, nickname='TestWallet', override_address=random_address())

    def update(self, dest: ts4.Address, value: int):
        self.call_method('update', {
            'dest': dest,
            'value': value,
        })
        ts4.dispatch_messages()

    def make_bid(self,
                 dest: ts4.Address,
                 value: int,
                 bid_value: int,
                 expect_ec: int = 0):
        self.call_method('makeBid', {
            'dest': dest,
            'value': value,
            'bidValue': bid_value,
        })
        ts4.dispatch_one_message(expect_ec=expect_ec)
        ts4.dispatch_messages()

    def send_transaction(self,
                         dest: ts4.Address,
                         value: int,
                         bounce: bool = False,
                         flags: int = 0,
                         payload=ts4.EMPTY_CELL):
        self.call_method('sendTransaction', {
            'dest': dest,
            'value': value,
            'bounce': bounce,
            'flags': flags,
            'payload': payload,
        })
        # ts4.dispatch_one_message()
        ts4.dispatch_messages()
