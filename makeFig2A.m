clc
clear
close all
addpath(genpath('data'))
addpath(genpath('code'))

load subjects_ID
[bouma, area] = crowding_summary_data();

S_low_bouma = strcmp('sub-wlsubj045',subjects);
S_high_bouma = strcmp('sub-wlsubj117',subjects);


boumas = [bouma(S_low_bouma) bouma(S_high_bouma)];

%% visualize letter diagrams for two subjects
% Note that for visualization purposes we don't show letters below
% eccentricity = 1

for b = 1 : length(boumas)
    
    crowding_Visualize_Letters(boumas(b),2,0.24,10,0,1)
    
    axis off
end
