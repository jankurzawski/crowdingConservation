clc
clear
close all
addpath(genpath('./../data'))
addpath(genpath('./../extra'))
addpath(genpath('./../TLS'))

load bouma_factors.mat
load surface_size.mat
load subjects_ID
load mycmap

bouma_factors = geomean([bouma_S1';bouma_S2']);


rois = {'V1';'V2';'V3';'hV4'};
r = 2;

S_low_bouma = strcmp('sub-wlsubj045',subjects)
S_high_bouma = strcmp('sub-wlsubj117',subjects)


boumas_radial = [bouma_factors(S_low_bouma) bouma_factors(S_high_bouma)];
boumas_tangential = boumas_radial / r;
boumas            = boumas_radial / sqrt(r);
%% calc num letters

for b = 2% : length(boumas)
    
    crowding_Visualize_Letters(boumas(b),2,0.24,10,0, 1, 1)
    
    axis off
end
