import tonos_ts4.ts4 as ts4

from abstract.base import BaseAuctionTest
from utils.phase import Phase


class CommonAuctionTest(BaseAuctionTest):
    START_TIME = 10
    OPEN_DURATION = 30

    def _setup_phase_time(self, phase: Phase, update: bool = False):
        if phase == Phase.WAIT:
            ts4.core.set_now(self.START_TIME - 1)
        if phase == Phase.OPEN:
            ts4.core.set_now(self.START_TIME + 1)
        if phase == Phase.CONFIRMATION:
            raise Exception('Undefined phase for "CommonAuction"')
        if phase == phase.CLOSE:
            ts4.core.set_now(self.START_TIME + self.OPEN_DURATION + 1)

        if update:
            self._update()
