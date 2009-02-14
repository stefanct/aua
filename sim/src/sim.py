from cpu import Cpu
from utils import *

from sys import stdin
import re
import readline

def print_help():
    print "b [address] \n\tSet one or more brakepoints.\nIf no address given a list of all breakpoints is displayed."
    print "bt \n\tPrint backtrace.\n"
    print "c[ontinue] \n\tContinue program after breakpoint.\n"
    print "h[elp] \n\tPrint help.\n"
    print "p[rint] <register|address> \n\tPrint a register or data at the address specified.\n"
    print "r[un] \n\tRun the program. If already running, restart. Use c[ontinue] if you do not want to restart.\n"

def print_no_cpu():
    print "No cpu loaded."

c = Cpu()
c.load("../../as/boot")
input = readline.get_line_buffer()
while len(input) == 0 or input[0] != "q":
    
    if len(input) > 0:
        
        if input[0] == "b":
            if len(input) > 1:
                c.add_brakepoint(input[1:])
            else:
                breakpoints = map(hex, c.list_brakepoints())
                if len(breakpoints) > 0:
                    print map(hex, c.list_brakepoints())
                else:
                    print "No breakpoints have been set yet."
        
        elif input[0] == "bt":
            c.print_backtrace()
        
        elif input[0] == "c" or input[0] == "continue":
            c.run()
        
        elif input[0] == "h" or input[0] == "help":
            print_help()
        
        elif input[0] == "p" or input[0] == "print":
            if c == 0:
                print print_no_cpu()
                continue
            if len(input) > 1:
                if input[1][0] == "$": # Register ausgeben
                    if len(input[1]) == 1:
                        print "No valid register specified."
                    else:
                        try:
                            reg = int(input[1][1:], 10)
                            if reg < 0 or reg > 31:
                                print "Valid registers: r0..r31"
                            else:
                                print hex(c.get_reg(reg))
                        except:
                            print "No valid register specified."
                        
                else: # Speicher ausgeben
                    try:
                        addr = int(input[1], 0)
                        if addr < 0 or addr > (1 << 16):
                            print "Address out of range. Valid addresses must be within 0..", hex(1 << 16)
                        else:
                            addr &= 0xfffe
                            print hex(addr), ":", hex(c.get_mem(addr))
                    except:
                        print "No valid address specified."
            else:
                print "No register/address specified."
        
        elif input[0] == "r" or input[0] == "run":
            c.reset()
            c.run()
        
        elif input[0] == "regs":
            c.print_regs()
        
        else:
            print "Unknown command, see h[elp] for a list of valid commands."

    input = raw_input('> ').split()

