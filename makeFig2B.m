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

S_low_bouma = strcmp('sub-wlsubj045',subjects);
S_high_bouma = strcmp('sub-wlsubj117',subjects);
boumas = [bouma(S_low_bouma) bouma(S_high_bouma)];
%% visualize letter diagrams for two subjects
% Note that for visualization purposes we show only a quarter of letters
% centered at the horizontal meridian

for b = 1 : length(boumas)
    
    crowding_visualize_Letters(boumas(b),2,0.24,10,0,1);
    axis off
    addlines(10);
    
end


function [h] = addlines(r)

    % add eccentricity ring
    th = 0:pi/50:2*pi;
    h = polarplot(th,r+zeros(size(th)),'Color',[0 0 0 0.15],'LineStyle',':','LineWidth',2);
    
    % add wedge outline
    polarplot([deg2rad(45) deg2rad(45)],[0 10],'Color',[0 0 0 0.15],'LineStyle',':','LineWidth',2)
    polarplot([deg2rad(-45) deg2rad(-45)],[0 10],'Color',[0 0 0 0.15],'LineStyle',':','LineWidth',2)
    
    % add fixation
    polarplot([deg2rad(0) deg2rad(0)],[-0.5 0.5],'Color',[0 0 0],'LineStyle','-','LineWidth',2)
    polarplot([deg2rad(90) deg2rad(90)],[-0.5 0.5],'Color',[0 0 0],'LineStyle','-','LineWidth',2)
    
end