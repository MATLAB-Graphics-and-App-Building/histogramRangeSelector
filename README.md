# histogramRangeSelector

[![View histogramRangeSelector on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/95833-histogramrangeselector)

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=MATLAB-Graphics-and-App-Building/histogramRangeSelector)

Version: 1.0

![histogramRangeSelector](/example_histogramRangeSelector.png)

This component is designed to allow specification of minimum and maximum values for an intensity image, or independently for the RGB channels of an image.
It features a histogram for showing the intensity data and editfields with accompanying lines for setting the minimum and maximum.
When the values change, the MinChanged/MaxChanged events fire.

How to use:
```
c = histogramRangeSelector; % create the component

im = imread('myimage.png');     % read an image
[n,x]=histcounts(im(:),0:255);  % collect histogram data
set(c,'HistogramBinEdges',x,'HistogramBinCounts',n);


c.MinChangedFcn=@myMinChangedFunction;
c.MaxChangedFcn=@myMaxChangedFunction;
```
