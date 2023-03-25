Command Format: each command is 16 bits. [15:12] bits are used as opcode, [11:0] bits are used as operand.
 
opcode = 8 is used to control the leds, if operand bit [8]=1 then LEDs will blink, if operand bit [8]=0 then LEDs will display operand bits [7:0];
Example commands: 0x8100 -> Leds will work in Blinky mode.
0x80CC -> Leds will work in display 11001100.

To read FT600 FIFO: The below command sequence is required to set a 24 bit read_length register and to read that many shorts of data.
opcode=1, operand = LSB 12bits of read length in shorts.
opcode=2, operand = MSB 12bits of read length in shorts.
opcode=3, operand = 0. (Operand is ignored); -> this command will trigger fpga to write the read_lenght number of shorts in to FT_FIFO when it is not full.

Example: Command sequence to read 1 Mega Bytes data from FT600 FIFO.
0x1000;
0x2080;
0x3000;
Then read 1 Mega shorts from FPGA. which is 0x080_000 shorts.

Example: Command sequence to read 1 Short data from FT600 FIFO.
0x1001;
0x2000;
0x3000;
Then read 1 short (2 Bytes) from FPGA.

The read data from FIFO is incremental SHORT data by +1 starting from 0x0001, then goes like 0x0002, 0x0003, etc...
