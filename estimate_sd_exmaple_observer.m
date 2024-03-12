clc
clear
close all
[directory,~] = fileparts(mfilename('fullpath'));
cd(directory);
addpath(genpath('data'))
addpath(genpath('code'))
addpath(genpath('extra'))

load subjects_ID
two_sess = 3; % if equal 3 load get all 8 crowding thr per observer
[bouma, area] = load_from_raw([],3);


S_low_bouma = strcmp('sub-wlsubj045',subjects);
S_high_bouma = strcmp('sub-wlsubj117',subjects);
boumas = [bouma(:,S_low_bouma,:) bouma(:,S_high_bouma,:)];

subj_mean = NaN(1,2);
subj_sd    = NaN(1,2);

for s = 1 : size(subj_mean,2);
    
    subj_data = squeeze(boumas(:,s,:));
    subj_mean(s) = geomean(geomean(subj_data));
    subj_sd(s) = mean(std(subj_data));
    
end