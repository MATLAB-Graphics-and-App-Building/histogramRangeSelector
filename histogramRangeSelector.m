classdef histogramRangeSelector < matlab.ui.componentcontainer.ComponentContainer
% histogramRangeSelector   Custom component for selecting a range absed on
% a histogram.
%
%   histogramRangeSlector is a custom component to place into an app to
%   allow app users to select a range based on a set of values. It shows a
%   histogram and allows users to select a minimum and maximum value based
%   on the histogram. When these values are selected, the MinChangedFcn and
%   MaxChangedFcn callbacks execute.
%
%   Use the left and right mouse buttons to interactively select minimum
%   and maximum values, or enter them in the edit fields within the
%   component.
%
%   Properties:
%   ===========
%   HistogramBinEdges, HistogramBinCounts : the edges and counts to be
%   displayed in the histogram. The HISTCOUNTS function is useful for
%   getting these values.
%
%   Min, Max : The currently selected minimum and maximum values.
%
%   Color : Color for the histogram display
%
%   MinChangedFcn, MaxChangedFcn : callback functions that execute when the
%   Min and Max values change.

% Copyright 2021 The MathWorks, Inc.

    properties
        HistogramBinEdges (1,:) double = []
        HistogramBinCounts (1,:) double = []
        Min (1,1) double = 0
        Max (1,1) double = 255
        Color {validatecolor} = [.6 .6 .6]
    end

    properties(Access=private, Transient)
        Grid matlab.ui.container.GridLayout
        Ax matlab.ui.control.UIAxes
        HistBar matlab.graphics.chart.primitive.Histogram
        MinLine matlab.graphics.chart.decoration.ConstantLine
        MaxLine matlab.graphics.chart.decoration.ConstantLine
        MinEdit matlab.ui.control.EditField
        MaxEdit matlab.ui.control.EditField

        LeftPatch matlab.graphics.primitive.Patch
        RightPatch matlab.graphics.primitive.Patch

        HistogramDirty = true;
    end

    events (HasCallbackProperty, NotifyAccess=protected)
        MinChanged
        MaxChanged
    end

    methods (Access=protected)
        function setup(obj)
            % Create Top-Level grid, and Uiaxes that will hold Histogram
            obj.Grid = uigridlayout(obj, [2 1], 'RowHeight', {'1x' 22}, ...
                'Padding',0, 'RowSpacing', 0);
            obj.Ax = uiaxes(obj.Grid, 'XTick', [], 'YTick', [], ...
                'Box', 'on', 'XLim', [0 255]);

            % Disable default interactivity, and enable custom interaction
            disableDefaultInteractivity(obj.Ax)
            obj.Ax.ButtonDownFcn = @(~,~)obj.buttoncallback;

            % Disable toolbar
            obj.Ax.Toolbar = [];

            % Add the histogram to the axes and patches to 'grey' out the
            % region outside of the min/max
            obj.HistBar = histogram(obj.Ax, 'HitTest', 'off', ...
                'EdgeColor', 'none', 'FaceAlpha', 1, 'FaceColor', obj.Color);
            obj.LeftPatch = patch(obj.Ax, 'FaceColor', 'w', ...
                'FaceAlpha', .5, 'EdgeColor', 'none', 'HitTest', 'off');
            obj.RightPatch = patch(obj.Ax, 'FaceColor', 'w', ...
                'FaceAlpha', .5, 'EdgeColor', 'none', 'HitTest', 'off');

            % Add the minimum and maximum lines
            obj.MinLine = xline(obj.Ax, 0, 'LineWidth', 1);
            obj.MaxLine = xline(obj.Ax, 255, 'LineWidth', 1);

            % Create a nested grid to hold the edit fields
            lowergrid = uigridlayout(obj.Grid, [1 3], ...
                'ColumnWidth', {45 '1x' 45}, 'Padding', 0);
            obj.MinEdit = uieditfield(lowergrid, 'Value', string(obj.Min), ...
                'ValueChangedFcn', @obj.chgMinEdit);
            obj.MaxEdit = uieditfield(lowergrid, 'Value', string(obj.Max), ...
                'ValueChangedFcn', @obj.chgMaxEdit);
            obj.MaxEdit.Layout.Column = 3;
        end

        function update(obj)
            % Only update the histogram if there's data, and it's changed
            if ~isempty(obj.HistogramBinEdges) && obj.HistogramDirty
                set(obj.HistBar, 'BinEdges', obj.HistogramBinEdges, ...
                    'BinCounts', obj.HistogramBinCounts)
                obj.Ax.XLim = obj.HistogramBinEdges([1 end]);
                obj.Ax.YLim = [0 max(obj.HistogramBinCounts)];
                % Make sure the current min and max fit in the new
                % histogram edges:
                obj.Min = max(obj.Min, obj.Ax.XLim(1));
                obj.Max = min(obj.Max, obj.Ax.XLim(2));
            end
            obj.HistBar.FaceColor=obj.Color;
            % Set the 'greyed' out regions using xlim and ylim and Min/Max
            xl = obj.Ax.XLim;
            yl = obj.Ax.YLim;
            obj.LeftPatch.XData = [xl(1) xl(1) obj.Min obj.Min];
            obj.LeftPatch.YData = [yl(1) yl(2) yl(2) yl(1)];

            obj.RightPatch.XData = [xl(2) xl(2) obj.Max obj.Max];
            obj.RightPatch.YData = [yl(1) yl(2) yl(2) yl(1)];
        end
    end

    methods
        function set.Min(obj, val)
            obj.MinLine.Value = val;
            obj.MinEdit.Value = string(val);
            obj.Min = val;
            notify(obj, 'MinChanged')
        end
        function set.Max(obj, val)
            obj.MaxLine.Value = val;
            obj.MaxEdit.Value = string(val);
            obj.Max = val;
            notify(obj, 'MaxChanged')
        end
        function set.HistogramBinEdges(obj, val)
            obj.HistogramBinEdges = val;
            obj.HistogramDirty = true;
        end
        function set.HistogramBinCounts(obj, val)
            obj.HistogramBinCounts = val;
            obj.HistogramDirty = true;
        end
    end

    methods (Access=private)
        function buttoncallback(obj)

            cx = obj.Ax.CurrentPoint(1);

            % Get the figure ancestor to determine whether it was a left or
            % right click.
            fig=ancestor(obj.Ax,'figure');
            but=fig.SelectionType;

            if strcmp(but,'normal')
                % Left click changes Min, but clamp it to the range of the
                % histogram and the current Max.
                obj.Min = min(max(cx, obj.Ax.XLim(1)), obj.Max);
            elseif strcmp(but,'alt')
                % Right click changes Max, but clamp it to the range of the
                % histogram and the current Min.
                obj.Max = max(min(cx, obj.Ax.XLim(2)), obj.Min);
            end
        end
        function chgMinEdit(obj, ~, event)
            % Callback for user change to Min editfield: validate and set
            val = str2double(event.Value);
            if val >= obj.Max || val < obj.Ax.XLim(1)
                obj.MinEdit.Value = event.PreviousValue;
            else
                obj.Min = val;
            end
        end
        function chgMaxEdit(obj,~,event)
            % Callback for user change to Max editfield: validate and set
            val = str2double(event.Value);
            if val <= obj.Min || val > obj.Ax.XLim(2)
                obj.MaxEdit.Value = event.PreviousValue;
            else
                obj.Max = val;
            end
        end
    end
end