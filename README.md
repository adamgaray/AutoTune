# AutoTune

AutoTune is a rudimentary pitch corrector. Auto-tuning is an audio processing effect that can allow sounds to be perfectly tuned despite being oringally off-pitch by determining the desired frequency in equal temperament and shifting the frequency by a calculated ratio. This is implemented with a phase vocoder.

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






