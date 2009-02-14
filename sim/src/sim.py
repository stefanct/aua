from cpu import Cpu
from utils import *

from sys import stdin
import re
import readline

def print_help():
    print "HELP"
    print "  h[elp] \n\tPrint this help.\n"
    
    print "\nNAVIGATING"
    print "  r[un] \n\tRun the program. If already running, restart. Use c[ontinue] if you do not want to restart.\n"
    print "  c[ontinue] \n\tContinue program after breakpoint.\n"
    print "  n[ext] <nr>\n\tProcess <nr> instructions. If <nr> not given process one single instruction.\n"
    
    print "\nSTATE INFORMATION"
    print "  i[nfo] \n\tPrint state information (backtrace, cyclecount).\n"
    print "  bt \n\tPrint backtrace.\n"
    print "  regs \n\tPrints values of all registers.\n"
    print "  p[rint] <register|address> \n\tPrint a register or data at the address specified.\n"
    
    print "\nCAPTURING"
    print "  b [address] \n\tSet one or more brakepoints."
    print "  \tIf no address given a list of all breakpoints is displayed.\n"
    print "  d[elete] <nr> \n\tDeletes breakpoint number <nr>.\n"
    print "  w[watch] <register> \n\tTriggers changes in a register specified."
    print "  \tIf no register is specified lists all watchpoints set.\n"
    print "  dw <nr> \n\tDeletes watchpoint number <nr>.\n"
    

def print_no_cpu():
    print "No cpu loaded."

print "AUA interactive debugging shell 0.1"

c = Cpu()
c.load("../../as/boot")
input = readline.get_line_buffer()
while len(input) == 0 or input[0] != "q":
    
    if len(input) > 0:
        
        if input[0] == "b":
            if len(input) > 1:
                c.add_breakpoint(input[1:])
            else:
                breakpoints = c.list_breakpoints()
                if len(breakpoints) > 0:
                    for i in range(len(breakpoints)):
                        print i+1, "\t", hex(breakpoints[i])
                        
                else:
                    print "No breakpoints have been set yet."
        
        elif input[0] == "bt":
            c.print_backtrace()
        
        elif input[0] == "c" or input[0] == "continue":
            c.run()
        
        elif input[0] == "d" or input[0] == "delete":
            if len(input) > 1:
                c.delete_breakpoint(input[1:])
            else:
                print "No breakpoints specified."
        
        elif input[0] == "dw":
            if len(input) > 1:
                c.delete_watchpoints(input[1:])
            else:
                print "No watchpoints specified."
        
        elif input[0] == "h" or input[0] == "help":
            print_help()
        
        elif input[0] == "i" or input[0] == "info":
            c.print_status()
        
        elif input[0] == "n" or input[0] == "next":
            if len(input) == 1:
                c.run(1)
            elif len(input) == 2:
                try:
                    c.run(int(input[1]))
                except:
                    print "No valid number of cycles given."
            else:
                print "No valid number of cycles given."
        
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
        
        elif input[0] == "w" or input[0] == "watch":
            if len(input) > 1:
                c.add_watchpoint(input[1:])
            else:
                watchpoints = c.list_watchpoints()
                if len(watchpoints) > 0:
                    for i in range(len(watchpoints)):
                        print i+1, "\t", hex(watchpoints[i])
                        
                else:
                    print "No watchpoints have been set yet."
        
        else:
            print "Unknown command, see h[elp] for a list of valid commands."

    input = raw_input('> ').split()

