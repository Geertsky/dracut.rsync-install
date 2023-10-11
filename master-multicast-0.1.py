from __future__ import print_function

from random import random
from threading import Timer
from time import sleep


def timeout():
    print("Alarm!")


t = Timer(10.0, timeout)
t.start()  # After 10 seconds, "Alarm!" will be printed

sleep(5.0)
if random() < 0.5:  # But half of the time
    t.cancel()  # We might just cancel the timer
    print("Canceling")
