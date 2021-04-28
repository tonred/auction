import tonos_ts4.ts4 as ts4

from abstract.base import BaseAuctionTest
from utils.phase import Phase


class CommonAuctionTest(BaseAuctionTest):
    START_TIME = 10
    OPEN_DURATION = 40

    def test_open_time(self):
        open_time = self.contract.call_getter('getOpenTime')
        open_time_expected = {
            'startTime': self.START_TIME,
            'finishTime': self.START_TIME + self.OPEN_DURATION,
        }
        self.assertEqual(open_time_expected, open_time, 'Open time is wrong')

    def test_phases(self):
        self.assertEqual(Phase.WAIT, self._phase(), 'Phase must be WAIT')

        self._setup_phase_time(Phase.OPEN, update=True)
        self.assertEqual(Phase.OPEN, self._phase(), 'Phase must be OPEN')

        self._setup_phase_time(Phase.CLOSE, update=True)
        self.assertEqual(Phase.CLOSE, self._phase(), 'Phase must be CLOSE')

    def _setup_phase_time(self, phase: Phase, update: bool = False):
        if phase == Phase.WAIT:
            ts4.core.set_now(self.START_TIME - 1)
        if phase == Phase.OPEN:
            ts4.core.set_now(self.START_TIME + self.OPEN_DURATION // 2)
        if phase == Phase.CONFIRMATION:
            raise Exception('Undefined phase for "CommonAuction"')
        if phase == phase.CLOSE:
            ts4.core.set_now(self.START_TIME + self.OPEN_DURATION + 1)

        if update:
            self._update()
