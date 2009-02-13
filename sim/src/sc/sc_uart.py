from sc.sc_device import *

class ScUart(ScDevice):
    
    def __init__(self, address, mask):
        ScDevice.__init__(self)
        self.name = "UART"
        self.base = address
        self.mask = mask
    
    def ld(self, address):
        if address == self.base:
            self._wait_cycles = 1
            self._data = 1
    
    def st(self, address, data):
        print "[UART]: ", data
    
    def get_data(self):
        if self.is_ready():
            return False
        else:
            return self.data