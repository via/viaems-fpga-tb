import sys
import struct 


def encode_delay(delay):
    assert delay < (2**25)
    byte1 = 0xD0 | ((delay & 0x01e00000) >> 21);
    byte2 = ((delay & 0x001fc000) >> 14);
    byte3 = ((delay & 0x00003f80) >> 7);
    byte4 = (delay & 0x7f)
    return struct.pack("BBBB", byte1, byte2, byte3, byte4)

def encode_output(delay, output):
    assert delay < (2**17)
    byte1 = 0xC0 | ((delay & 0x0001e000) >> 13)
    byte2 = ((delay & 0x00001fc0) >> 6)
    byte3 = (delay & 0x0000003f) | (output & 0x80)
    byte4 = output & 0x7f
    return struct.pack("BBBB", byte1, byte2, byte3, byte4)

def encode_adc(sel, val1, val2):
    byte1 = 0x80 | (sel << 3) | (val1 >> 9)
    byte2 = (val1 >> 2) & 0x7f
    byte3 = ((val1 & 0x3) << 5) | (val2 >> 7)
    byte4 = val2 & 0x7f;
    return struct.pack("BBBB", byte1, byte2, byte3, byte4)

def convert_time(d):
    return int((15/4.0) * d)

def produce_delay(val):
    delay = val
    while delay > 0:
        delay = val - 1 # Command itself always takes 1
        this_delay = (2**25) - 1 if delay >= (2**25) else delay
        sys.stdout.buffer.write(encode_delay(this_delay))
        delay -= this_delay 

def produce_trigger(delay, trigger):
    
    # Produce rising edge with delay of 4 clocks
    bits = 0x1 if trigger == 0 else 0x2
    sys.stdout.buffer.write(encode_output(0, bits))

    # Produce falling edge with remaining delay
    delay -= (4 + 1)
    if delay < 0:
        delay = 0

    this_delay = (2**17) - 1 if delay >= (2**17) else delay
    sys.stdout.buffer.write(encode_output(this_delay, 0))

    delay -= this_delay 

    if delay > 0:
        produce_delay(delay)

    



#sys.stdout.buffer.write(encode_adc(0, 0xae3, 0x246))
sys.stdout.buffer.write(encode_adc(1, 1170, 0))
#sys.stdout.buffer.write(encode_adc(5, 2048, 2048))
while True:
    sys.stdout.buffer.write(encode_adc(1, 1170, 0))
    sys.stdout.buffer.write(encode_delay(int(15000000/2)))
    sys.stdout.buffer.write(encode_adc(1, 2500, 0))
    sys.stdout.buffer.write(encode_delay(int(15000000/2)))

#produce_delay(15000000)
#for line in sys.stdin:
#    if line.startswith("a"):
#        d = int(line.split()[1])
#        produce_delay(convert_time(d))
#
#    elif line.startswith("t"):
#        d = int(line.split()[1])
#        t = int(line.split()[2])
#        produce_trigger(convert_time(d), t)
