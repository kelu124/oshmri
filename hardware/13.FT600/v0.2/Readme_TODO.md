FT600 updates


## Missing Pullups 

* TODO -- Pullup for SIWU_N (10k to 3.3v)
* TODO -- Pullup for WAKEUP_N (10k to 3.3v)


## DV10 not outputting
Main thing seen: 
- There was no 1V out of DV10.

Propositions to correct for v0.4:

- VD10 connects to (all) DV10 (and AVDD)
- Pins 19:30 (VCC3) need to be connected (all, not only 15)
- Pins 26/37/50 need to be connected to Pin 31
- C14 == 4.7uF
- Pins 52/44/38 connected to VCCIO

Tests points (pads) on the bottom layer:
- 3.3V
- 5V
- VCCIO
- DV10
- VCC3.3

## Adjustments
	
* Add VBUS: 5v + 470R + greenled
