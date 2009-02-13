import sys
from utils import *
from sc_master import *
from sc.sc_uart import *

class Cpu:

    def __init__(self):
        self.__pc = 0x8000
        self.__registers = [0] * 32
        self.__memory = [0 for x in range(1 << 16)]
        scm = ScMaster()
        uart = ScUart(0xff20, 0xfff0)
        scm.add(uart)
        self.__scm = scm
        self.__waiting = ()
        self.__waiting_cycles = 0
        self.__sram_wait_cycles = 1
        self.__cycles = 0
    
    def load(self, filename):
        file = open(filename, mode='rb')
        a = 1
        addr = 0x8000
        while a:
            a = file.read(1);
            self.__memory[addr] = a
            addr += 1
        file.close()
        
        print (addr - 0x8000) >> 1, "words loaded"
    
    def unknown(self):
        print "Instruction invalid or not yet implemented"
    
    def ld(self, address, reg):
        if address < 0x8000: # SRAM
            self.__waiting = (0, address, reg)
            self.__waiting_cycles = self.__sram_wait_cycles
        elif address < 0x9000: # ROM
            self.__registers[reg] = self.__memory[address]
        else:
            self.__scm.ld(address)
            self.__waiting = (0, reg)
            
    def st(self, address, reg):
        if address < 0x8000: # SRAM
            self.__waiting = (1, address, reg)
            self.__waiting_cycles = self.__sram_wait_cycles
        elif address < 0x9000: # ROM
            pass
        else:
            pass
        
    def run(self, cycles):
        while cycles:
            
            print "--- TICK ", self.__cycles, "---"
            self.__cycles += 1
            
            cycles -= 1
            
            self.__scm.tick()
            
            if self.__waiting.__len__() == 0:
                instruction = [0] * 2
                for i in range(2):
                    instruction[i] = self.__memory[self.__pc + i]
                    if instruction[i]:
                        instruction[i] = ord(instruction[i])
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
                    self.__registers[31] = self.__pc
                    self.__pc = opb
                    
                elif instr <= 0x0e: # brez
                    if opa == 0:
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
                    self.__registers[opa] = to_signed(self.__registers[opa] + opb, 7)
                
                elif instr <= 0x1f: # muli
                    opb += ((instr & 0x3) << 5)
                    self.__registers[opa] = to_signed(self.__registers[opa] * opb, 7)
                
                elif instr <= 0x2f:
                    self.unknown()
                
                elif instr <= 0x30:
                    self.__registers[opa] <<= opb
                
                elif instr <= 0x3c:
                    self.unknown()
                
                elif instr <= 0x3d: # ld
                    self.ld(self.__registers[opb], opa)
                
                elif instr <= 0x3e: # st
                    self.st(self.__registers[opb], opa)
                
                    
                
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
                    self.pc += 2
                
                
            print "pc: ", hex(self.__pc), ", instr: ", hex(instr), ", opa: ", opa, ", opb: ", opb
            print map(lambda x: hex(x), self.__registers)
            if self.__waiting.__len__() == 0:
                self.__pc += 2
                

