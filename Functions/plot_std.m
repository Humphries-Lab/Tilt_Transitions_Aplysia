function plot_std(x,y,std_dev,Colour)
% plot_std
% Plots a mean curve with its corresponding standard deviation.
%
% INPUTS
%   x       - X-axis values.
%   y       - Mean values.
%   std_dev - Standard deviation values.
%   Colour  - Colour used for the curve and shaded area.
%
% The standard deviation is displayed as a semi-transparent shaded region
% around the mean curve.

select=~isnan(y);
x=x(select);
std_dev=std_dev(select);
y=y(select);



% check x and y are a row
x=x(:)';
y=y(:)';
std_dev=std_dev(:)';


curve1 = y + std_dev;
curve2 = y - std_dev;
x2 = [x, fliplr(x)];
inBetween = [curve1, fliplr(curve2)];

fill(x2, inBetween,Colour,'FaceAlpha',.5,'EdgeColor',Colour,'EdgeAlpha',.5);
hold on;
plot(x, y, 'Color',Colour, 'LineWidth', 2);
end
