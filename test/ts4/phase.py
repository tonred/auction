import enum


class Phase(enum.IntEnum):
    WAIT = 0
    OPEN = 1
    CONFIRMATION = 2
    CLOSE = 3
