class ScDevice:
    def __init__(self):
        self._name = ""
        self._address = 0
        self._mask = 0
        self._wait_cycles = 0
        self._data = False
    
    def getAddress(self):
        return _address
    
    def getMask(self):
        return _mask
    
    def tick(self):
        if self._wait_cycles > 0:
            self._wait_cycles -= 1
    
    def ld(self, address):
        print "Unknown device"
        return False        
    
    def st(self, address, data):
        print "Unknown device"
        return False

    def is_ready(self):
        if self._wait_cycles > 0:
            return False
        else:
            return True
    
    def get_data(self):
        print "Unknown device"
        return False