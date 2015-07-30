clear
close all;

data = csvread('result.csv',1);
cpu_speed = 16000000;
time_per_cycle = 1/cpu_speed;
cycles = data/time_per_cycle;

[f,x] = hist(cycles, 15);
%H = histfit(cycles,15, 'burr');

% Setup figure properties.
fontSize = 10;
fontSizeAxes = 8;
fontWeight = 'normal';
figurePosition = [440 378 400 150];   % [x y width height]

hFig = figure(1);
set(hFig, 'Position', figurePosition)
set(gcf,'Renderer','painters');
hold on;
norm = f/sum(f);
b = bar(x,norm);
%hist(cycles,15)
%histfit(cycles,15, 'burr')
pd = fitdist(cycles, 'burr');
xdata = [100000:600000];

y = pdf(pd, xdata);
y = y*32000;
a = plot(xdata,y,'r');
legend();
axis([150000,580000,-inf,0.3]);
set(gca, 'xtick',[150000, 200000,300000,400000,500000]);
set(gca,'XTickLabel',{'','200','300','400','500',})
legend([a],'Fit')
box on;

h = xlabel('Thousand MCU instruction cycles');
set(h,'FontSize',fontSize);
set(h,'fontweight', fontWeight);

h = ylabel('Probability');
set(h,'FontSize',fontSize);
set(h,'fontweight', fontWeight);