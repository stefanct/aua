from sc.sc_device import *

import readline

class ScUart(ScDevice):
    
    def __init__(self, address, mask):
        ScDevice.__init__(self)
        self._name = "UART"
        self._base = address
        self._mask = mask
    
    def ld(self, address):
        if address == self._base:
            self._wait_cycles = 1
            self._data = 1
    
    def st(self, address, data):
        print "[UART]: ", _data
    
    def get_data(self):
        if self.is_ready():
            input = ""
            while len(input) < 1:
                input = raw_input('[UART] Reading byte: ')
            try:
                input = int(input, 0)
            except:
                input = ord(input[0])
            return input
        else:
            return False