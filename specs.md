# OSHMRI

## Overview

The basic schematic of an MRI system is shown in Figure 1. The MRI spectrometer is responsible for playing out the RF and gradient pulses and receiving the MR signal and manages logic signals.

Overall strategy is: First make it work, then make it nice (=cheaper & more open source). 

Low cost (500eur) design for educational purposes and low budget. 3 typical freqs:

* 0.05 T - central freq 2.15MHz, 20kHz to 50kHz bandwidth
* 0.1  T - central freq 4 MHz, up to 500kHz bandwidth
* 0.3  T - central freq 13MHz, up to 500kHz bandwidth
* 0.5  T - central freq 21 MHz, up to 500kHz bandwidth

## Requirements

Maybe it's good for me to share what (hardware wise) the 'ideal' spectrometer requirements would look:

* 1xRF transmit channel - 16bit+
  * Voltage range: up to 1Vpp	
  * Sampling speed and nb bits: `@what@` -> _flexible_
  * Duration of transmit: up to 10ms, typically shorter.
* 4x kHz gradients transmits - (~250 kHz) ~20 bit dacs for the gradient waveforms
  * 4 SPIs ?
* 1x RF receive - Central freq @2, 4, 13 or 21Mhz. 
  * _BW on the Rx side nice-to-have would be 500 kHz, practically I think 50 kHz would satisfy most needs_
  * ADC 16bit 
  * Duration of acquisition : up to 20ms
  * Gain for acquisition : 0 to 30dB
* Ability to daisy chain for multiple receive channels (up to e.g. 16 or 32 RX channels would be great in the future to get an SNR boost)
* High frequency and phase stability (accurate and stable timings below 1us (preferably much less) jitter). One of the most important things in MR is the timing, both for transmission and reception (please check the IPSO part of the bruker hardware manual that I have attached). 

GPIO pins to communicate with peripherals for for instance amplifier deblanking. Logic:
* Blanking
* Sampling on
* Gradients On
* Pulse On

## Storage
* Images are 256x256*256 or above, 16bits imaginary
  * 64MB / image
  * 256kB / plane

## Ideas

PMODs! 8 IOs = loads

* Transmit: AD9102 - 20 EUR
  * 14 bits, 180Msps, 4096 word pattern
  * @180msps, 4096pts = 22us.

## RF

### Overall

![](/images/specs/RF_Overview.png)

On the RF image, green represents acquisitions. Do you confirm that's for the 3 ADCs?
I agree that might be a bit confusing. Green is not the acquisition, it is the gradient. There are three gradients for different purposes and the acquisition (sampling) is in between two gradients (orange and green in TSE sequence description.png)) and during x gradient (blue) at 10ms, 20ms, 30ms etc. This is a single line of the MR image and this pulse sequence is being repeated multiple times (e.g. 128 or 256). The lengths of the pulse sequence is called TR repetition time. A better understanding is here (check fast spin echo and the signal location, thats where ADC sampling kicks in). There is only one ADC for sampling the receiving signal per RF receive coil channel. One thing that is being done and that boost SNR is to have multiple RF receiver channels. Thats why my previous comment to have an option to add or connect more Rx channels later would be great. For transmission at the moment 1 RF channel is sufficient. More would be interesting, but more from research perspective and at the moment 1 is sufficieent. For the gradients we need 3Tx. Forget about the 64MHz for the moment (we dont have 1.5T magnets for the OSH stuff anyway at the moment) if its too complicated, we can focus on the low field MR systems up to 0.5T (So in total 1xRF @ 1 or 2MHz - 22MHz. ven up to 0.2T or 0.3T, ca 13MHz would be fine).

### Gradients

![](/images/specs/GradientWaveforms.png)


![](/images/specs/Blockpulse-Zoomed.png)
![](/images/specs/FIDPingPong.png)


![](/images/specs/Sinc_pulse.png)
![](/images/specs/TSE_seq.png)

## Blocks


### RF acquisitions

* And how long does it take? I'm reading roughly 10ms acquisitions. _The sinc pulse that is shown is for transmission, which is around 10ms. They can be also shorter. For the acquisition it will be typically shorter (e.g. in the TSE sequence image that I have sent you it is around 5ms, but it could be higher e.g. 20ms (see also docs from answer below))_
* At 64Msps that's quite some data (64*10*1000 points). _Yes MRI scans produce quite some data, but there are also some tricks. Have a look here: http://mri-q.com/receiver-bandwidth.html and here: [bandwidthinmrisiemens.pdf](pdfs/bandwidthinmrisiemens.pdf)._

### Gradients

* On the gradient waveforms, do you confirm that's more or less constants (ie square pulses)? _The gradient waveforms are mostly trapezoidal. There are some more fancy things with arbitrary gradient waveforms, but for classical MR that would be ok._

### Block pulses

* I trust the Block pulse is a gate pulse - what is its lengths? A ms or so ? _There will be a pulse to gate the RF power amplifier and the TR switches. The pulse lengths depends on the RF pulse lenghts. So sth like 1-5ms._

## Competition

'It has shortcomings too. I think one of the reasons we've decided to work with it now is that it is being adopted across multiple sites so that the development burden is shared.'


## To sort

* https://upcommons.upc.edu/handle/2117/90394?locale-attribute=en FT600 +SDR
   * https://www.maximintegrated.com/en/products/analog/data-converters/analog-front-end-ics/MAX5866.html

* AD8339 better ? DC to 50MHz


## Resources:

* https://www.researchgate.net/publication/232935201_A_digital_receiver_module_with_direct_data_acquisition_for_magnetic_resonance_imaging_systems
  * AD9852 DDS + direct sampling
* https://www.researchgate.net/publication/231108694_A_single-board_NMR_spectrometer_based_on_a_software_defined_radio_architecture
* https://www.researchgate.net/publication/51189854_A_versatile_pulse_programmer_for_magnetic_resonance_imaging
* https://www.researchgate.net/publication/265176277_Comparison_of_Analog_and_Digital_Transceiver_Systems_for_MR_Imaging


