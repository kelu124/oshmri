# -*- coding: utf-8 -*-
"""
Created on Thu Jan  6 23:18:33 2022

@author: to_reilly
"""

import numpy as np
import matplotlib.pyplot as plt

fileIdx = np.arange(0,64)

rawRFdata       = []
rawGradData     = [] #contains the frequency encoding gradient
rawPhaseData    = [] #contains the phase encoding gradient
# rawPulseData    = [] #data containing the blanking signal from the RF amp, (in this case, with hard pulses) represent the envelope of the RF pulse 

for idx in fileIdx:
    rawRFdata.append(np.genfromtxt(r'Raw data/C1--Line--%05d.csv'%(idx), delimiter = ',', skip_header = 5))
    rawGradData.append(np.genfromtxt(r'Raw data/C2--Line--%05d.csv'%(idx), delimiter = ',', skip_header = 5))
    rawPhaseData.append(np.genfromtxt(r'Raw data/C3--Line--%05d.csv'%(idx), delimiter = ',', skip_header = 5))
    # rawPulseData.append(np.genfromtxt(r'Raw data/C4--Line--%05d.csv'%(idx), delimiter = ',', skip_header = 5))
    
rawRFdata   = np.array(rawRFdata)
rawGradData = np.array(rawGradData)
rawPhaseData= np.array(rawPhaseData)

plt.figure()
plt.plot(rawGradData[63,:,0]*1e3, rawGradData[63,:,1],label = "Frequency encoding gradient")
plt.plot(rawPhaseData[63,:,0]*1e3, rawPhaseData[63,:,1],label = "Phase encoding gradient")
plt.xlabel("Time [ms]")
plt.ylabel("Voltage [V]")
plt.legend()

timeScale   = rawRFdata[0,:,0]*1e6
dt          = timeScale[1] - timeScale[0]

acqWindow   = 3.2*1e3       #length of acquisition window
echoTime    = 15*1e3 + 150  #echo time and center of the acquisition window
centerFreq  = 2.1485        #center frequency
BW          = 20*1e-3       #imaging bandwidth

#grab only the RF data in the correct acquisition window, determined by TE, BW and resolution
timeWindow  = np.where((echoTime - acqWindow/2 < timeScale) & (timeScale < echoTime + acqWindow/2))[0]
startWindow = timeWindow[0]
endWindow   = timeWindow[-1]

cutRFdata   = rawRFdata[:,startWindow:endWindow+1,1]
cutTimeScale= timeScale[startWindow:endWindow+1]
frequencies = np.fft.fftshift(np.fft.fftfreq(np.size(cutTimeScale), d = dt))

# only show in the correct frequency range
freqWindow  = np.where((centerFreq - BW/2 < frequencies) & (frequencies < centerFreq + BW/2))[0]
startFreq   = freqWindow[0]
endFreq     = freqWindow[-1]

#reorder the data in to the correct kspace position, center out trajectory
ordRFdata   = np.zeros(np.shape(cutRFdata))
ordRFdata[32:,:]   = cutRFdata[1::2,:] 
ordRFdata[:32,:]   = np.flip(cutRFdata[::2,:], axis = 0) 


image       = np.fft.fftshift(np.fft.fft2(np.fft.fftshift(ordRFdata)))
cutImage    = image[:,startFreq:endFreq+1]

plt.figure()
plt.imshow(np.abs(cutImage), cmap = 'gray')