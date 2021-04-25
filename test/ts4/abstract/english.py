from abstract.common import CommonAuctionTest


class EnglishAuctionTest(CommonAuctionTest):

    def _check_bids_count(self, expected: int):
        actual = self.contract.call_getter('getBidsCount')
        self.assertEqual(expected, actual)
