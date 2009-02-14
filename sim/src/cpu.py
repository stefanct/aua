import sys
from utils import *
from sc_master import *
from sc.sc_uart import *

class Cpu:

    def __init__(self):

        self.__file = ""

        self.__sram_wait_cycles = 1

        self.__breakpoints = []
        
        self.reset()

    def reset(self):
        self.__pc = 0x8000
        self.__registers = [0] * 32
        self.__carry = 0
        self.__memory = [0 for x in range(1 << 16)]
        scm = ScMaster()
        uart = ScUart(0xff20, 0xfff0)
        scm.add(uart)
        self.__scm = scm
        self.__waiting = ()
        self.__waiting_cycles = 0
        self.__cycles = 0
        self.__backtrace = []
        self.__load()
    
    def __load(self):
        if len(self.__file) >0:
            file = open(self.__file, mode='rb')
            a = 1
            addr = 0x8000
            a = file.read(1);
            while a:
                self.__memory[addr] = ord(a)
                addr += 1
                a = file.read(1);
            file.close()
            
            print (addr - 0x8000) >> 1, "words loaded"
    
    def load(self, filename):
        self.__file = filename
        self.__load()
    
    def unknown(self):
        print "Instruction invalid or not yet implemented"
    
    def __ld(self, address, reg):
        if address < 0x8000: # SRAM
            self.__waiting = (0, address, reg)
            self.__waiting_cycles = self.__sram_wait_cycles
        elif address < 0x9000: # ROM
            self.__registers[reg] = self.__memory[address]
        else:
            self.__scm.ld(address)
            self.__waiting = (0, reg)
            
    def __st(self, address, reg):
        if address < 0x8000: # SRAM
            self.__waiting = (1, address, reg)
            self.__waiting_cycles = self.__sram_wait_cycles
        elif address < 0x9000: # ROM
            pass
        else:
            pass
    
    def add_brakepoint(self, addresses):
        if len(addresses) == 1:
            try:
                a = int(addresses[0], 0)
                self.__breakpoints.append(a)
                print "Added brakepoint at", hex(a)
            except:
                print "No valid breakpoint address."
        
        else:
            good = []
            bad = []
            for a in addresses:
                try:
                    a = int(a, 0)
                except:
                    pass
                if type(a) == int:
                    good += [a]
                else:
                    bad += [a]
            if len(good) > 0:
                print "Added brakepoints at", map(hex, good)
                self.__breakpoints += good
            else:
                print "Added no brakepoints as no valid addresses were given."
            if len(bad) > 0:
                print "Ignored invalid addresses", bad
    
    def list_brakepoints(self):
        return sorted(self.__breakpoints)
    
    def print_regs(self):
        for line in range(0, 4):
            print reduce(lambda x,y: x + y, map(lambda x: hex(x) + "  ", self.__registers[line * 8:line * 8 + 8]))
    
    def get_reg(self, reg):
        return self.__registers[reg]
    
    def get_mem(self, addr):
        return (self.__memory[addr] << 8) + self.__memory[addr+1]
    
    def print_backtrace(self):
        if len(self.__backtrace) == 0:
            print hex(self.__pc)
        else:
            print reduce(lambda x, y: x + " -> " + y, map(hex, self.__backtrace)) + " -> " + hex(self.__pc)
    
    def run(self):
        while True:
            
            self.__cycles += 1
            
            self.__scm.tick()
            
            if self.__waiting.__len__() == 0:
                instruction = [0] * 2
                for i in range(2):
                    instruction[i] = self.__memory[self.__pc + i]
                instr = 0
                instr = instruction[0]
                instr >>= 2
                
                opa = instruction[1] & 0x1f
                opb = (instruction[1] & 0xe0) >> 5
                opb += (instruction[0] & 0x3) << 3
                
                if instr <= 0x07: # ldi
                    opb += ((instr & 0x7) << 5)
                    self.__registers[opa] &= 0xff00
                    self.__registers[opa] |= opb
                    
                elif instr <= 0x0c:
                    unknown
                
                elif instr <= 0x0d: # jmpl
                    self.__registers[31] = self.__pc + 2
                    self.__backtrace.insert(0, self.__pc)
                    self.__pc = self.__registers[opb]
                    
                elif instr <= 0x0e: # brez
                    if opa == 0:
                        if opb == 31:
                            self.__backtrace.pop(0)
                        self.__pc = to_signed(opb, 16)
                
                elif instr <= 0x0f: # brnez
                    if opa != 0:
                        self.__pc = to_signed(opb, 16)
                        
                elif instr <= 0x13: # brezi
                    opb += ((instr & 0x3) << 5)
                    if opa == 0:
                        self.__pc += to_signed(opb * 2 + 2, 8)
                
                elif instr <= 0x17: # brnezi
                    opb += ((instr & 0x3) << 5)
                    if opa != 0:
                        self.__pc += to_signed(opb * 2 + 2, 8)
                
                elif instr <= 0x1b: # addi
                    opb += ((instr & 0x3) << 5)
                    self.__registers[opa] = self.__registers[opa] + opb
                    if self.__carry > 0:
                        self.__registers[opa] += 1
                    self.__registers[opa] = to_unsigned(self.__registers[opa], 16)
                
                elif instr <= 0x1f: # muli
                    opb += ((instr & 0x3) << 5)
                    self.__registers[opa] = to_unsigned(self.__registers[opa] * opb, 16)
                
                elif instr <= 0x20: # add
                    self.__registers[opa] = self.__registers[opa] + self.__registers[opb]
                    if self.__carry > 0:
                        self.__registers[opa] += 1
                    self.__registers[opa] = to_unsigned(self.__registers[opa], 16)
                    
                elif instr <= 0x21: # addc
                    self.__registers[opa] = self.__registers[opa] + self.__registers[opb]
                    if self.__carry > 0:
                        self.__registers[opa] += 1
                    if self.__registers[opa] >= (1 << 16): 
                        self.__carry = 2
                        self.__registers[opa] = to_unsigned(self.__registers[opa], 16)
                
                elif instr <= 0x22: # sub
                    self.__registers[opa] = self.__registers[opa] - self.__registers[opb]
                    if self.__carry > 0:
                        self.__registers[opa] += 1
                    

                elif instr <= 0x23: # subc
                    self.__registers[opa] = self.__registers[opa] - self.__registers[opb]
                    if self.__registers[opa] < 0 or self.__registers[opa] >= (1 << 16): # TODO: subc = wtf
                        self.__carry = 2
                        self.__registers[opa] = to_unsigned(self.__registers[opa], 16)
                
                elif instr <= 0x27:
                    self.unknown()
                                    
                elif instr <= 0x28: # or
                    self.__registers[opa] |= self.__registers[opb]
                    
                elif instr <= 0x29: # and
                    self.__registers[opa] &= self.__registers[opb] 
                
                elif instr <= 0x2f:
                    self.unknown()
                
                elif instr <= 0x30: # lsli
                    self.__registers[opa] <<= opb
                
                elif instr <= 0x3b:
                    self.unknown()
                
                elif instr <= 0x3c: # ld
                    self.__ld(self.__registers[opb], opa)
                
                elif instr <= 0x3d:
                    self.unknown()
                
                elif instr <= 0x3e: # st
                    self.__st(self.__registers[opb], opa)
                
                else:
                    self.unknown()
                    
                
            if self.__waiting.__len__() == 3: # SRAM
                if self.__waiting_cycles > 0:
                    self.__waiting_cycles -= 1
                else:
                    if self.__waiting[0] == 0: # ld
                        self.__registers[self.__waiting[2]] = memory[1];
                    else: # st
                        self.__memory[1] = self.__registers[self.__waiting[2]]
                    self.__waiting = ()
                    self.__pc += 2
            
            elif self.__waiting.__len__() == 2: # SC
                if self.__scm.is_ready():
                    if self.__waiting[0] == 0: # ld
                        self.__registers[self.__waiting[1]] = self.__scm.get_data()
                    else: # st
                        pass
                    self.__waiting = ()
                    self.__pc += 2
                
                
            if self.__waiting.__len__() == 0:
                self.__pc += 2
                
            if self.__breakpoints.__contains__(self.__pc):
                print "Reached breakpoint at", hex(self.__pc), "Cycle", self.__cycles
                return 0
            
