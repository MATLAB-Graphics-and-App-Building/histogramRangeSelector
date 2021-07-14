# histogramRangeSelector

Version: 1.0

![histogramRangeSelector](/histogramRangeSelector/example_histogramRangeSelector.png)

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

Some additional demo apps are included: histogramRangeSelectorDemo which lets you set the RGB ranges for an image, and histogramRangeSelectorWebcamDemo which subclasses histogramRangeSelectorDemo and uses your webcam for the image data. Note that this requires MATLAB Support Package for USB Webcams 

![histogramRangeSelector](/histogramRangeSelector/example_histogramRangeSelectorWebcamDemo.png)