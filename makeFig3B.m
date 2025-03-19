clc
clear
close all
[directory,~] = fileparts(mfilename('fullpath'));
cd(directory);
addpath(genpath('data'))
addpath(genpath('code'))
addpath(genpath('extra'))

load subjects_ID
[bouma, area] = load_from_raw();

cmap(2,:) = [181 84 158]
cmap(1,:) = [31 117 188]
cmap = round(cmap/255,3)


S_low_bouma = strcmp('sub-wlsubj045',subjects);
S_high_bouma = strcmp('sub-wlsubj117',subjects);
boumas = [bouma(S_low_bouma) bouma(S_high_bouma)];
%% visualize letter diagrams for two subjects
% Note that for visualization purposes we show only a quarter of letters
% centered at the horizontal meridian

for b = 1 : length(boumas)
    
    crowding_visualize_Letters(boumas(b),2,0.24,10,0,1,'r',cmap(b,:));
    axis off
    
end

polarplot([deg2rad(0) deg2rad(0)],[-0.5 0.5],'Color',[0 0 0],'LineStyle','-','LineWidth',2)
polarplot([deg2rad(90) deg2rad(90)],[-0.5 0.5],'Color',[0 0 0],'LineStyle','-','LineWidth',2)

