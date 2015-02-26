clear

filename = '450cm';
data = csvread(strcat('dataset/', filename, '.csv'));
result = data(find(data < 0.035 & data > 0.012));
m = mean(result);
i = figure('visible', 'off');
hist(result, 20)
title(strcat('Mean = ', num2str(m)));

saveas(i, strcat('output/', filename, '.png'), 'png');

