from cpu import Cpu
from utils import *

c = Cpu()
c.load("../../as/boot")
c.run(50)