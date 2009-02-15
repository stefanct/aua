from sc.ScDevice import *

import readline

class ScUart(ScDevice):
    
    def __init__(self, address, mask):
        ScDevice.__init__(self)
        self._name = "UART"
        self._base = address
        self._mask = mask
    
    def ld(self, address):
        if address & self._mask == self._base:
            self._wait_cycles = 1
            self.__address = address
    
    def st(self, address, data):
        print "[UART]: ", _data
    
    def get_data(self):
        if self.is_ready():
            input = ""
            
            what = "invalid element" + hex(self.__address)
            if self.__address == self._base:
                what = "status"
            elif self.__address == self._base + 1:
                what = "data"
            
            while len(input) < 1:
                input = raw_input("[UART] Reading " + what + ": ")
            try:
                input = int(input, 0)
            except:
                input = ord(input[0])
            return input
        else:
            return False