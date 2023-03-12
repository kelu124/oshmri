# Code

[Code lives here](blinky/)

# Connections

I wired the FT2232 as followed:
TDO        AD2
TCK        AD0
TDI         AD1
TMS        AD3
GND       GND
IDCODE: 0x21111043 (LFE5U-12)


# Succes

Using JTAG [ECPPROG](https://github.com/gregdavill/ecpprog/tree/main/ecpprog).

```
pi@rpi:~/SA $ ecpprog -S hardware.bit
init..
IDCODE: 0x21111043 (LFE5U-12)
ECP5 Status Register: 0x00000e00
reset..
ECP5 Status Register: 0x00000e10
programming..
ECP5 Status Register: 0x00200100
Bye.
```

# Demo

![](blinky.gif)
