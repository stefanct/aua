from sc.ScDevice import *

class ScMaster:
    
    def __init__(self):
        self.__sc_devices = []
        self.__active_device = False
    
    def tick(self):
        map(lambda d: d.tick(), self.__sc_devices)
    
    def add(self, device):
        self.__sc_devices.append(device)
    
    def find_device(self, address):
        for device in self.__sc_devices:
             if device.getAddress() == address & device.getMask():
                 return device
        return False
    
    def ld(self, address):
        device = self.find_device(address)
        if device:
            device.ld(address)
            self.__active_device = device
        else:
            print "device not found at ", hex(address)
    
    def st(self, address, data):
        device = self.find_device(address)
        if device:
            device.st(address, data)
            self.__active_device = device
        else:
            print "device not found at ", hex(address)
    
    def is_ready(self):
        if self.__active_device == False:
            return True
        else:
            if self.__active_device.is_ready():
                return True
            else:
                return False
    
    def get_data(self):
        if self.__active_device == False:
            return False
        else:
            return self.__active_device.get_data()
    
    def set_data(self):
        if self.__active_device == False:
            return False
        else:
            return self.__active_device.set_data()