% Wipe workspace.
clear;

% Get filenames of dataset.
d = dir('dataset/TEK00*.CSV');
names = {d.name};

% Figure placeholder.
i = figure('visible', 'off');

% Set a threshold for filtering resulting paired extrema
threshold = 0.3;

% Choose smoothness for the reconstructed function.
smoothness = 'biharmonic';

% The data term weight affects how closely the reconstructed function adheres to the data.
data_weight = 0.0000001;

% Compile cpp.
mex run_persistence1d.cpp;

% Turn on mosek optimizer.
turn_on_mosek();

for name_index = 1:45,
	
	filename = strcat('dataset/', names{name_index})
	% Read CSV file.
	record_length   = csvread(filename, 0, 1, [0,1,0,1]);
	sample_interval = csvread(filename, 1, 1, [1,1,1,1]);
	data            = csvread(filename, 0, 4, [0,4, 2499, 4]);
	total_time      = record_length * sample_interval;
	
	% Input should be single precision.
	single_precision_data = single(data);
	
	[minIndices maxIndices persistence globalMinIndex globalMinValue] = run_persistence1d(single_precision_data);
	
	% Use filter_features_by_persistence to filter the pairs.
	persistent_features = filter_features_by_persistence(minIndices, maxIndices, persistence, threshold); 
	
	extremaIndices = [persistent_features(:,1) ;
	                  persistent_features(:,2) ;];
	
	% Plot the data with persistent features.
	plot_data_with_features(data, [extremaIndices; globalMinIndex]);
	title(strcat('extrema with persistence > ', num2str(threshold)));
	
	saveas(i, strcat('output/persistence_', names{name_index}, '.jpg'), 'jpg');
	
	% Reconstruct the data as a function.
	x = reconstruct1d(data, threshold, smoothness, data_weight);
	
	% --------------------- GET DISCHARGE TIMES ------------------------------------
	a = diff(x) < 0;
	b = diff(a);
	indices = [];
	
	len = 0;
	for j = 1:2498,
		if b(j) == 1
			len = j;
		elseif b(j) == -1
			len = j - len;
			indices = [indices; len];
		end
	end
	
	lengths = indices * sample_interval
end

% Turn off mosek optimizer.
turn_off_mosek();

