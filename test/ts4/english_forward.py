import os
import unittest

import tonos_ts4.ts4 as ts4


class TestBase(unittest.TestCase):
    START_TIME = 10
    OPEN_DURATION = 30

    @classmethod
    def setUpClass(cls):
        path = os.getcwd() + '/../../build-artifacts/'
        ts4.init(path, verbose=True)

    def setUp(self):
        ts4.core.set_now(self.START_TIME - 1)
        self.contract = ts4.BaseContract('EnglishForwardAuction', {
            'startValue': 1 * ts4.GRAM,
            'stepValue': 1 * ts4.GRAM,
            'startTime': self.START_TIME,
            'openDuration': self.OPEN_DURATION,
        })

    def test_start_time(self):
        open_time = self.contract.call_getter('getOpenTime')
        open_time_expected = {
            'startTime': self.START_TIME,
            'finishTime': self.START_TIME + self.OPEN_DURATION
        }
        self.assertEquals(open_time_expected, open_time)

    def test_phase(self):
        ts4.core.set_now(self.START_TIME + 1)
        self.contract.call_method('update')
        phase = self.contract.call_getter('getPhase')
        self.assertEquals(0, phase)

    def test_three_bids(self):
        self.contract.call_method('makeBid', {

        })


if __name__ == '__main__':
    print(ts4.G_TESTS_PATH)
    unittest.main()
