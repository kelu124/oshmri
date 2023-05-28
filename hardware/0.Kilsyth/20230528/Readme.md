I've used 6 LEDs from D5 to D10 for the debug purpose.



LEDs D3 and D4 can be controlled with FT Commands as earlier.



{D7,D6,D5} LEDs are directly connected to the FSM state register in the design.
localparam IDLE = 3'd0;
localparam RD_CMD = 3'd1;
localparam DECODE = 3'd2;
localparam WR_ADC_CNT = 3'd3;
localparam LOOPBACK = 3'd4;
localparam ADC_CAPTURE = 3'd5;
localparam WR_ADC_DATA = 3'd6;
Based on {D7,D6,D5} LEDs, we can know the current state of the FPGA. It should return to all zeroes (IDLE) after completion of every command.



D8,D9,D10 LEDs will always 0, but goes to 1 when the adc trigger is received at various stages of the design.
D8- high when trigger is received
D9- high when internal ADC Buffer is full.
D10 - high when ADC sample transmission on FT600 starts.
{D7,D6,D5} ={0,0,0}=IDLE means last sample is sent and FPGA is waiting to receive next command.
# Test

send 0xA000

wait for some time to complete the acquisition/or check the FT_GPIO1 to be 0, FT_GPIO1 will be high during adc acquisition.

Then read 8192 shorts


