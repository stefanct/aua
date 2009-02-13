from sc.sc_device import *

class ScMaster:
    
    def __init__(self):
        self.__sc_devices = []
        self.__active_devices = False
    
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
        device = find_device(address)
        if device:
            device.ld(address)
            self.__active_devices = device
        else:
            print "device not found"
    
    def st(self, address, data):
        device = find_device(address)
        if device:
            device.st(address, data)
            self.__active_devices = device
        else:
            print "device not found"
    
    def is_ready(self):
        if self.__active_devices == False:
            return True
        else:
            return self.__active_devices.is_ready()
    
    def get_data(self):
        if self.__active_devices == False:
            return False
        else:
            return self.active_device.get_data