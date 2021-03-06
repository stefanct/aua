import sys
from utils import *
from ScMaster import *
from sc.ScUart import *
from sc.ScDigits import *

class Cpu:

    def __init__(self):

        self.__file = ""

        self.__sram_wait_cycles = 1

        self.__breakpoints = []
        self.__watch = []
        self.__trace = 0
        
        self.reset()

    def reset(self):
        self.__pc = 0x8000
        self.__registers = [0] * 32
        self.__carry = 0
        self.__memory = [0 for x in range(1 << 16)]
        
        scm = ScMaster()
        self.__scm = scm
        uart = ScUart(0xff20, 0xfff0)
        scm.add(uart)
        digits = ScDigits(0xff10, 0xfff0)
        scm.add(digits)
        
        self.__waiting = {"type": 0}
        self.__waiting_cycles = 0
        self.__cycles = 0
        self.__backtrace = []
        self.__load()
        self.__changed_regs = []
    
    def __load(self):
        if len(self.__file) > 0:
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
    
    def add_breakpoint(self, addresses):
        if len(addresses) == 1:
            try:
                a = int(addresses[0], 0)
                self.__breakpoints.append(a)
                print "Added breakpoint", len(self.__breakpoints), "at", hex(a)
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
                print "Added breakpoints at", map(hex, good)
                self.__breakpoints += good
            else:
                print "Added no breakpoints as no valid addresses were given."
            if len(bad) > 0:
                print "Ignored invalid addresses", bad
    
    def delete_breakpoint(self, breakpoints):
        good = []
        bad = []
        out = []
        for b in breakpoints:
            try:
                b = int(b)
                if b > 0 and b <= len(self.__breakpoints):
                    good += [b]
                else:
                    out += [b]
            except:
                bad += [b]
        for g in sorted(good, reverse=True):
            self.__breakpoints.pop(g - 1)
        if len(good) > 0:
            print "Removed breakpoints:", good
        else:
            print "Deleted no breakpoints as no valid were specified."
        if len(bad) > 0:
            print "Ignored invalid breakpoints", bad
        if len(out) > 0:
            print "Ignored not-existing breakpoints", out
        
    def list_breakpoints(self):
        return self.__breakpoints
    
    def add_watchpoint(self, registers):
        good = []
        bad = []
        for r in registers:
            try:
                if r[0] != "$":
                    raise "NoRegister"
                r = int(r[1:])
                if r >= 0 and r <= 31:
                    good += [r]
                else:
                    bad += [r]
            except:
                bad += [r]
                
        for r in good:
            self.__watch += [r]
        if len(good) > 0:
            print "Added watchpoints for registers", reduce(lambda x, y: x + " " + str(y), map(lambda x: "$" + str(x), good))
        else:
            print "Added no watchpoints as no valid registers were specified."
        if len(bad) > 0:
            print "Ignored invalid registers", bad
    
    def list_watchpoints(self):
        return self.__watch
    
    def delete_watchpoints(self, watchpoints):
        good = []
        bad = []
        for w in watchpoints:
            try:
                w = int(w)
                if w > 0 and w <= len(self.__watch):
                    good += [w]
                else:
                    bad += [w]
            except:
                bad += [w]
        for g in sorted(good, reverse=True):
            self.__watch.pop(g - 1)
        if len(good) > 0:
            print "Removed watchpoints:", good
        else:
            print "Deleted no watchpoints as no valid were specified."
        if len(bad) > 0:
            print "Ignored invalid watchpoints", bad

    def print_regs(self):
        for line in range(0, 4):
            print reduce(lambda x, y: x + y, map(lambda x: hex(x) + "\t", self.__registers[line * 8:line * 8 + 8]))
    
    def get_reg(self, reg):
        return self.__registers[reg]
    
    def get_mem(self, addr):
        return (self.__memory[addr] << 8) + self.__memory[addr + 1]
    
    def print_backtrace(self):
        if len(self.__backtrace) == 0:
            print hex(self.__pc)
        else:
            print reduce(lambda x, y: x + " -> " + y, map(hex, self.__backtrace)) + " -> " + hex(self.__pc)
    
    def print_status(self):
        print "Cycles since reset:", self.__cycles
        if len(self.__backtrace) == 0:
            print "Backtrace:", hex(self.__pc)
        else:
            print "Backtrace:", reduce(lambda x, y: x + " -> " + y, map(hex, self.__backtrace)) + " -> " + hex(self.__pc)
        print "$fp:", hex(self.__registers[30]), "\t$sp:", hex(self.__registers[29]) 
    
    def set_trace(self, state):
        self.__trace = state
    
    def __checkwatch(self):
        for c in self.__changed_regs:
            if self.__watch.__contains__(c):
                print "Watched register $" + str(c) + " changed at " + hex(self.__pc - 2) + ": " + hex(self.__registers[c])
                return True
        return False
    
    def __ld(self, address, reg, mask=False):
        if address < 0x8000: # SRAM
            self.__waiting["action"] = "ld"
            self.__waiting["type"] = "sram"
            self.__waiting["cycles"] = self.__sram_wait_cycles
            self.__waiting["address"] = address
            self.__waiting["register"] = reg
            self.__waiting["mask"] = mask
        elif address < 0x9000: # ROM
            self.__registers[reg] = self.__memory[address]
        else:
            self.__scm.ld(address)
            self.__waiting["action"] = "ld"
            self.__waiting["type"] = "sc"
            self.__waiting["register"] = reg
            self.__waiting["mask"] = mask
            
    def __st(self, address, reg, mask=False):
        if address < 0x8000: # SRAM
            self.__waiting["action"] = "st"
            self.__waiting["type"] = "sram"
            self.__waiting["cycles"] = self.__sram_wait_cycles
            self.__waiting["address"] = address
            self.__waiting["register"] = reg
            self.__waiting["mask"] = mask
        elif address < 0x9000: # ROM
            pass
        else:
            print "store", address, reg, mask
            self.__scm.st(address, self.__registers[reg])
            self.__waiting["action"] = "st"
            self.__waiting["type"] = "sc"
    
    def run(self, count=0):
        limit = False
        if count > 0:
            limit = True
        
        while limit == False or count > 0:
            
            if self.__trace == 1:
                print "PC:", hex(self.__pc)
            
            if count > 0:
                count -= 1
            
            self.__changed_regs = []
            
            self.__cycles += 1
            
            self.__scm.tick()
            
            if self.__waiting["type"] == 0:
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
                    self.__changed_regs += [opa]
                    
                elif instr <= 0x0c:
                    self.unknown()
                
                elif instr <= 0x0d: # jmpl
                    self.__registers[31] = self.__pc + 2
                    self.__backtrace.insert(0, self.__pc)
                    self.__pc = self.__registers[opb] - 2
                    self.__changed_regs += [31]
                    
                elif instr <= 0x0e: # brez
                    if self.__registers[opa] == 0:
                        if opb == 31:
                            self.__backtrace.pop(0)
                        self.__pc = to_unsigned(self.__registers[opb] - 2, 16)
                
                elif instr <= 0x0f: # brnez
                    if self.__registers[opa] != 0:
                        self.__pc = to_unsigned(self.__registers[opb] - 2, 16)
                        
                elif instr <= 0x13: # brezi
                    opb += ((instr & 0x3) << 5)
                    if self.__registers[opa] == 0:
                        self.__pc += to_signed(opb * 2 - 2, 8)
                
                elif instr <= 0x17: # brnezi
                    opb += ((instr & 0x3) << 5)
                    if self.__registers[opa] != 0:
                        self.__pc += to_signed(opb * 2 - 2, 8)
                
                elif instr <= 0x1b: # addi
                    opb += ((instr & 0x3) << 5)
                    self.__registers[opa] = self.__registers[opa] + to_signed(opb, 7)
                    if self.__carry > 0:
                        self.__registers[opa] += 1
                    self.__registers[opa] = to_unsigned(self.__registers[opa], 16)
                    self.__changed_regs += [opa]
                
                elif instr <= 0x1f: # muli
                    opb += ((instr & 0x3) << 5)
                    self.__registers[opa] = to_unsigned(self.__registers[opa] * opb, 16)
                    self.__changed_regs += [opa]
                
                elif instr <= 0x20: # add
                    self.__registers[opa] = self.__registers[opa] + self.__registers[opb]
                    if self.__carry > 0:
                        self.__registers[opa] += 1
                    self.__registers[opa] = to_unsigned(self.__registers[opa], 16)
                    self.__changed_regs += [opa]
                    
                elif instr <= 0x21: # addc
                    self.__registers[opa] = self.__registers[opa] + self.__registers[opb]
                    if self.__carry > 0:
                        self.__registers[opa] += 1
                    if self.__registers[opa] >= (1 << 16): 
                        self.__carry = 2
                        self.__registers[opa] = to_unsigned(self.__registers[opa], 16)
                    self.__changed_regs += [opa]
                
                elif instr <= 0x22: # sub
                    self.__registers[opa] = self.__registers[opa] - self.__registers[opb]
                    if self.__carry > 0:
                        self.__registers[opa] += 1
                    self.__changed_regs += [opa]

                elif instr <= 0x23: # subc
                    self.__registers[opa] = self.__registers[opa] - self.__registers[opb]
                    if self.__registers[opa] < 0 or self.__registers[opa] >= (1 << 16): # TODO: subc = wtf
                        self.__carry = 2
                        self.__registers[opa] = to_unsigned(self.__registers[opa], 16)
                    self.__changed_regs += [opa]
                
		    	elif instr <= 0x24: # mul
					self.__registers[opa] = to_unsigned(to_signed(self.__registers[opa], 16) * to_signed(self.__registers[opb], 16), 32) & 0xffff
                    self.__changed_regs += [opa]

				elif instr <= 0x25: # mulu
					self.__registers[opa] = to_unsigned(self.__registers[opa] * self.__registers[opb], 32) & 0xffff
                    self.__changed_regs += [opa]

				elif instr <= 0x26: # mulh
					self.__registers[opa] = to_unsigned(to_signed(self.__registers[opa], 16) * to_signed(self.__registers[opb], 16), 32) >> 0x10
                    self.__changed_regs += [opa]

				elif instr <= 0x27: # mulhu
					self.__registers[opa] = to_unsigned(self.__registers[opa] * self.__registers[opb], 32) >> 0x10
                    self.__changed_regs += [opa]

                elif instr <= 0x28: # or
                    self.__registers[opa] |= self.__registers[opb]
                    self.__changed_regs += [opa]
                    
                elif instr <= 0x29: # and
                    self.__registers[opa] &= self.__registers[opb] 
                    self.__changed_regs += [opa]
                
				elif instr <= 0x2a: # xor
					self.__registers[opa] = to_unsigned(self.__registers[opa] ^ self.__registers[opb], 16)
                    self.__changed_regs += [opa]
				
				elif instr <= 0x2b: # not
					self.__registers[opa] = to_unsigned(~self.__registers[opb], 16)
                    self.__changed_regs += [opa]
				
				elif instr <= 0x2c: # neg
					self.__registers[opa] = to_unsigend(0 - self.__registers[opb], 16)
                    self.__changed_regs += [opa]
				
				elif instr <= 0x2d: # asr TODO
					pass

				elif instr <= 0x2e: # lsl
					self.__registers[opa] = to_unsigned(self.__registers[opa] << self.__registers[opb], 16)
                    self.__changed_regs += [opa]

				elif instr <= 0x2f: # lsr
					self.__registers[opa] = to_unsigned(self.__registers[opa] >> self.__registers[opb], 16)
                    self.__changed_regs += [opa]

                elif instr <= 0x30: # lsli
                    self.__registers[opa] <<= opb
                    self.__changed_regs += [opa]
                
				elif instr <= 0x31: # lsri
					self.__registers[opa] >>= opb
                    self.__changed_regs += [opa]
				
				elif instr <= 0x32: # scb
					if opb >= 0x10:
						self.__registers[opa] |= 1 << (opb & 0xf)
					else:
						self.__registers[opa] &= ~(1 << (opb & 0xf))

				elif instr <= 0x3b:
                    self.unknown()
                
                elif instr <= 0x3c: # ld
                    self.__ld(self.__registers[opb], opa)
                    self.__changed_regs += [opa]
                
                elif instr <= 0x3d:
                    self.unknown()
                
                elif instr <= 0x3e: # st
                    self.__st(self.__registers[opb], opa)
                
                elif instr <= 0x3f: # stb
                    self.__st(self.__registers[opb], opa, True)
                
                else:
                    self.unknown()
                    
            
            if self.__waiting["type"] == "sram":
                if self.__waiting["cycles"] > 0:
                    self.__waiting["cycles"] -= 1
                else:
                    if self.__waiting["action"] == "ld":
                        if self.__waiting["mask"]: # nur ein Byte
                            self.__registers[self.__waiting["register"]] &= 0xff00
                            self.__registers[self.__waiting["register"]] |= self.__memory[self.__waiting["address"]] & 0xff
                        else:
                            self.__registers[self.__waiting["register"]] = self.__memory[self.__waiting["address"] & 0xfffe] << 8
                            self.__registers[self.__waiting["register"]] |= self.__memory[self.__waiting["address"] | 1]
                   
                    else: # st
                        if self.__waiting["mask"]: # nur ein Byte
                            print "st mask"
                            self.__memory[self.__waiting["address"]] = self.__registers[self.__waiting["register"]] & 0xff
                        else:
                            print "st no mask"
                            self.__memory[self.__waiting["address"] & 0xfffe] = self.__registers[self.__waiting["register"]] >> 8
                            self.__memory[self.__waiting["address"] | 1] = self.__registers[self.__waiting["register"]] & 0xff
                    
                    self.__waiting["type"] = 0
            
            elif self.__waiting["type"] == "sc": # TODO: mask
                if self.__scm.is_ready():
                    if self.__waiting["action"] == "ld":
                        self.__registers[self.__waiting["register"]] = self.__scm.get_data()
                    else: # st
                        self.__scm.set_data()
                    self.__waiting["type"] = 0
                
                
            if self.__waiting["type"] == 0:
                self.__pc += 2
            
            if self.__checkwatch():
                return 0
            self.__changed_regs = []
                
            if self.__breakpoints.__contains__(self.__pc):
                print "Reached breakpoint at", hex(self.__pc), "Cycle", self.__cycles
                return 0
            
