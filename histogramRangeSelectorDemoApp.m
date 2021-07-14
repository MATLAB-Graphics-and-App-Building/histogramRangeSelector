classdef histogramRangeSelectorDemoApp < handle
% histogramRangeSelectorDemoApp: A small app that demonstrates the
% histogramRangeSelector custom component by displaying an image and offering
% interactive control of RGB min/max.

% Copyright 2021 The MathWorks, Inc.

    properties (Transient, Access=protected)
        fig
        lay
        ax
        im

        hrs (1,3) histogramRangeSelector
        ImageData (:,:,3) uint8
    end


    methods
        function obj=histogramRangeSelectorDemoApp
            obj.fig = uifigure;
            obj.lay = uigridlayout(obj.fig, [4 2], ...
                        'ColumnWidth', {'1x' 150}, ...
                        'RowHeight',{100 100 100 'fit'});

            obj.ax=uiaxes(obj.lay,'XTick',[],'YTick',[],'Box','on');
            obj.ax.Layout.Row=[1 4];
            obj.im=image(obj.ax,zeros(0,0,3,'uint8'));
            axis(obj.ax,'image')

            obj.hrs(1)=histogramRangeSelector(obj.lay,'Color',[1 0 0]);
            obj.hrs(1).Layout.Row=1;
            obj.hrs(2)=histogramRangeSelector(obj.lay,'Color',[0 1 0]);
            obj.hrs(2).Layout.Row=2;
            obj.hrs(3)=histogramRangeSelector(obj.lay,'Color',[0 0 1]);
            obj.hrs(3).Layout.Row=3;

            for i = 1:3
                obj.hrs(i).MinChangedFcn=@(~,~)obj.rescaleColors;
                obj.hrs(i).MaxChangedFcn=@(~,~)obj.rescaleColors;
            end
        end
        function setImageData(obj,imdata)
            % update histograms
            for i = 1:3
                [obj.hrs(i).HistogramBinCounts,obj.hrs(i).HistogramBinEdges] = histcounts(imdata(:,:,i),0:255);
            end

            % update ImageData
            obj.ImageData=imdata;

            % Rescale colors (which will set the Image's CData
            obj.rescaleColors;
        end
    end
    methods (Access=private)
        function rescaleColors(obj)
            c=obj.ImageData;
            for i = 1:3
                c(:,:,i)=rescale(c(:,:,i),0,255,'InputMin',obj.hrs(i).Min,'InputMax',obj.hrs(i).Max);
            end
            obj.im.CData=c;
        end
    end

end
