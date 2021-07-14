function histogramRangeSelectorDemo
% histogramRangeSelectorDemo:   Function to call histogramRangeSelectorDemoApp
% and apply some image data.

% Copyright 2021 The MathWorks, Inc.

    im = imread('peppers.png');
    h = histogramRangeSelectorDemoApp;
    h.setImageData(im);
end