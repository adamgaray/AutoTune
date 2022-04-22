function outputVector = pitchShift(X, winSize, hop, ratio)

% Intermediate constants
hopOut = round(ratio*hop);

% Hanning window for overlap-add
wn = hann(winSize*2+1);
wn = wn(2:2:end);

% Rotate if needed
if size(X,1) < size(X,2)
    X = transpose(X);
end

X = [zeros(hop*3,1) ; X];

% Initialization

% Create a frame matrix for the current input
[y,numberFramesInput] = createFrames(X,hop,winSize);

% Create a frame matrix to receive processed frames
numberFramesOutput = numberFramesInput;
outputy = zeros(numberFramesOutput,winSize);

% Initialize cumulative phase
phaseCumulative = 0;

% Initialize previous frame phase
previousPhase = 0;

for index=1:numberFramesInput
    
% Analysis
    
    % Get current frame to be processed
    currentFrame = y(index,:);
    
    % Window the frame
    currentFrameWindowed = currentFrame .* wn' / sqrt(((winSize/hop)/2));
    
    % Get the FFT
    currentFrameWindowedFFT = fft(currentFrameWindowed);
    
    % Get the magnitude
    magFrame = abs(currentFrameWindowedFFT);
    
    % Get the angle
    phaseFrame = angle(currentFrameWindowedFFT);
    
% Processing    

    % Get the phase difference
    deltaPhi = phaseFrame - previousPhase;
    previousPhase = phaseFrame;
    
    % Remove the expected phase difference
    deltaPhiPrime = deltaPhi - hop * 2*pi*(0:(winSize-1))/winSize;
    
    % Map to -pi/pi range
    deltaPhiPrimeMod = mod(deltaPhiPrime+pi, 2*pi) - pi;
     
    % Get the true frequency
    trueFreq = 2*pi*(0:(winSize-1))/winSize + deltaPhiPrimeMod/hop;

    % Get the final phase
    phaseCumulative = phaseCumulative + hopOut * trueFreq;    
    
    % Remove the 60 Hz noise. This is not done for now but could be
    % achieved by setting some bins to zero.
   
% Synthesis    
    
    % Get the magnitude
    outputMag = magFrame;
    
    % Produce output frame
    outputFrame = real(ifft(outputMag .* exp(j*phaseCumulative)));
     
    % Save frame that has been processed
    outputy(index,:) = outputFrame .* wn' / sqrt(((winSize/hopOut)/2));
        
end

% Finalize

% Overlap add in a vector
outputTimeStretched = fusionFrames(outputy,hopOut);

% Resample with linearinterpolation
outputTime = interp1((0:(length(outputTimeStretched)-1)),outputTimeStretched,(0:ratio:(length(outputTimeStretched)-1)),'linear');

% Return the result
outputVector = outputTime;

return

%% CreateFrames
function [vectorFrames,numberSlices] = createFrames(x,hop,windowSize)

% Find the max number of slices that can be obtained
numberSlices = floor((length(x)-windowSize)/hop);

% Truncate if needed to get only a integer number of hop
x = x(1:(numberSlices*hop+windowSize));

% Create a matrix with time slices
vectorFrames = zeros(floor(length(x)/hop),windowSize);

% Fill the matrix
for index = 1:numberSlices
   
    indexTimeStart = (index-1)*hop + 1;
    indexTimeEnd = (index-1)*hop + windowSize;
    
    vectorFrames(index,:) = x(indexTimeStart: indexTimeEnd);
    
end

return

%% FusionFrames

function vectorTime = fusionFrames(framesMatrix, hop)

sizeMatrix = size(framesMatrix);

% Get the number of frames
numberFrames = sizeMatrix(1);

% Get the size of each frame
sizeFrames = sizeMatrix(2);

% Define an empty vector to receive result
vectorTime = zeros(numberFrames*hop-hop+sizeFrames,1);

timeIndex = 1;

% Loop for each frame and overlap-add
for index=1:numberFrames
   
    vectorTime(timeIndex:timeIndex+sizeFrames-1) = vectorTime(timeIndex:timeIndex+sizeFrames-1) + framesMatrix(index,:)';
    
    timeIndex = timeIndex + hop;
    
end

return