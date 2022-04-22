# AutoTune

AutoTune is a rudimentary pitch corrector. I wanted to create a project that would involve frequency-domain processing in MATLAB, and this project taught be a lot about the FFT and using a phase vocoder.

Auto-tuning is an audio processing effect that can allow sounds to be perfectly tuned despite being oringally off-pitch. The auto-tuner determines the desired frequency in equal temperament, and shifts the frequency by a calculated ratio.

## Usage

Ensure that `pitchShift.m` can be called from `auotune.m`.

AutoTune takes 3 inputs: The input sound file, its sampling frequency, and a window length.

Example usage:

```
[X, fs] = audioread('input.wav');
Y = autotune(X, fs, 1024);
soundsc(Y, fs);
```

## Project Overview

### Pre-Processing

Any input is compressed to mono using `mean`. Any stereo output will be average between the two channels, and output that is already mono will be unaffected. 

`nextpow2` rounds the window length to the nearest power of 2 for simplicity of the FFT. A Hamming window is generated with the size of the new window length.

### Frequency Calculation

For each window, the frequency is calculated using `max`. Note that even if the frequency selected with this method is a harmonic and not the fundamental frequency, both are out of tune by a constant ratio.

The frequency in equal temperament (A=440Hz) is found with the following function:

```
nearest = 2^(round(12*log2(freq/440))/12) * 400
```

### Phase Vocoder

I tried several different implementations for the pitch shifting, but eventually had the best results with one I found [here](http://www.guitarpitchshifter.com/algorithm.html).

The pitch shifter splits the window its given into frames with 75% overlap, performs an FFT, adjusts the phase, and performs an IFFT. It then does an overlap-add, and resamples with linear interpolation.

## Development Process, Results, and Project Improvement

This was a fun project that taught be a lot about the FFT, and frequency domain processing in general. The phase vocoder proved difficult to implement: I spent a lot of time trying my own implementation from scratch, but could not come up with one that I thought satisfactory. However, implementing the one linked above, as well as learning the math behind it, proved a rewarding experience, and I am now much more confident in concepts related to frequency domain processing.

Some sound outputs can be quite distorted. This is a result of phase non-linearities when combining windows after they have been individually pitch-shifted. Solving these phase non-linearities would make this project fully functional, but unfortunately I did not have time over the course of this project to implement a meaningful solution.

Overall I'm satisfied with my work; it's enjoyable to give funny screams or non-musical sounds as input and hear the auto-tuned result. Given the scope and amount of time dedicated, I think I created a reasonable prototype that I learned a lot from.







