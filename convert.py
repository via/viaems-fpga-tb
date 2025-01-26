import sys
import struct 


def convert_time(d):
    return int((15/4.0) * d)

def produce_delay(val):
    delay = val
    while delay > 0:
        delay = val - 1 # Command itself always takes 1
        this_delay = (2**26) if delay > (2**26) else delay

        byte1 = 0xC0 | ((this_delay & 0x07e00000) >> 21);
        byte2 = ((this_delay & 0x001fc000) >> 14);
        byte3 = ((this_delay & 0x00003f80) >> 7);
        byte4 = (this_delay & 0x7f)

        sys.stdout.buffer.write(struct.pack("BBBB", byte1, byte2, byte3, byte4))

        delay -= this_delay 

def produce_trigger(delay, trigger):
    
    # Produce rising edge with delay of 4 clocks
    bits = 0x1 if trigger == 0 else 0x2
    sys.stdout.buffer.write(struct.pack("BBBB", 0x80, 0x00, 0x08, bits))

    # Produce falling edge with remaining delay
    delay -= (4 + 1)
    if delay < 0:
        delay = 0

    this_delay = (2**17) if delay > (2**17) else delay

    byte1 = 0x80 | ((this_delay & 0x0001e000) >> 13)
    byte2 = ((this_delay & 0x00001fc0) >> 6)
    byte3 = (this_delay & 0x0000003f)
    byte4 = 0

    sys.stdout.buffer.write(struct.pack("BBBB", byte1, byte2, byte3, byte4))

    delay -= this_delay 

    if delay > 0:
        produce_delay(delay)

    




produce_delay(15000000)
for line in sys.stdin:
    if line.startswith("a"):
        d = int(line.split()[1])
        produce_delay(convert_time(d))

    elif line.startswith("t"):
        d = int(line.split()[1])
        t = int(line.split()[2])
        produce_trigger(convert_time(d), t)
