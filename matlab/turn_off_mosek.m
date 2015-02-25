%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TURN_OFF_MOSEK
%
% Removes MOSEK folders from Matlab path. 
% Use this file to switch back from using MOSEK optimizers to Matlab optimizers.
%
% Comment out the unnecessary lines, according to your installation directory.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = turn_off_mosek()
	rmpath '/home/jettan/mosek/7/toolbox/r2013a';
	% rmpath 'c:\Program Files\mosek\7\toolbox\r2012a'; 
	% rmpath 'c:\Program Files\mosek\7\toolbox\r2013a';
end