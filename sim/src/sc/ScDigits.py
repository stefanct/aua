from sc.ScDevice import *

import readline

class ScDigits(ScDevice):
    
    def __init__(self, address, mask):
        ScDevice.__init__(self)
        self._name = "DIGITS"
        self._base = address
        self._mask = mask
        
        self.__digits = [0xff] * 8
    
    def ld(self, address):
        if address == self._base:
            self._wait_cycles = 1
            self._address = address
    
    def st(self, address, data):
        self._address = address
        self._data = data
        if address <= self._base + 8:
            self.__digits[address - self._base] = data 
    
    def get_data(self):
        if self.is_ready():
            input = ""
            while len(input) < 1:
                input = raw_input("[DIGITS] Reading", hex(address), ';')
            try:
                input = int(input, 0)
            except:
                input = ord(input[0])
            return input
        else:
            return False
    
    def set_data(self):
        print "[DIGITS]: " + hex(self._data)
        
        line = "\t"
        for d in reversed(self.__digits):
            if d & 1:
                line += "    "
            else:
                line += " _  "
        print line
        
        line = "\t"
        for d in reversed(self.__digits):
            if d & 0x20:
                line += " "
            else:
                line += "|"
            if d & 4:
                line += " "
            else:
                line += "_"
            if d & 2:
                line += "  "
            else:
                line += "| "
        print line
        
        line = "\t"
        for d in reversed(self.__digits):
            if d & 0x10:
                line += " "
            else:
                line += "|"
            if d & 8:
                line += " "
            else:
                line += "_"
            if d & 4:
                line += " ."
            else:
                line += "|."
        print line + "\n"