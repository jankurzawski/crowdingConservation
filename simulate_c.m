clc
clear
close all

[directory,~] = fileparts(mfilename('fullpath'));
cd(directory);
addpath(genpath('data'))
addpath(genpath('code'))
addpath(genpath('extra'))

factors_to_boot = {'across_subjects';'within_subjects';'alpha';'phi0'};
% factors_to_boot = {'within_subjects'};

ecc_max = 10;
ecc_min = 0;

load_two_sessions = 1;
[bouma, area] = load_from_raw('midgray',load_two_sessions,[ecc_min ecc_max]);
roi = 4;
area = squeeze(area(:,roi,:));

n_obs = length(area);
bouma_means = mean(bouma);
area_means = mean(area);

bouma_std = std(bouma);
area_std = std(area);

alpha_mean = 2.1083;
alpha_std  = 0.3787;

phi_mean = 0.2429;
phi_std = 0.0513;

letters_picked = NaN(length(bouma_means),1);
areas_picked = NaN(length(bouma_means),1);

%%

nboots = 10000;

conservation_to_save = NaN(1,nboots);
r2_to_save = NaN(1,nboots);
alpha_to_save = NaN(1,nboots);
phi_to_save =  NaN(1,nboots);


choose = @(samples) samples(randi(numel(samples)));

if ~exist('factors_to_boot','var'); factors_to_boot = {};end

for x = 1 : nboots

    % for each iteration pick alpha and ecc_0

    if contains('alpha',factors_to_boot)
        alpha   = randn * alpha_std + alpha_mean;
    else
        alpha   = 2;
    end

    if contains('phi0',factors_to_boot)
        ecc_0   = randn * phi_std + phi_mean;
    else
        ecc_0   = 0.24;
    end

    while ecc_0 < 0
        ecc_0   = randn * phi_std + phi_mean;
    end

    for s = 1 : n_obs

        % for each subject pick bouma, and surface area based on the
        % distributions

    
        if contains('across_subjects',factors_to_boot)
            pickindex = choose(1:length(bouma_means));
        else
            pickindex = s;
        end

        if contains('within_subjects',factors_to_boot)
            B = randn .* bouma_std(pickindex) + bouma_means(pickindex);
        else
            B = bouma_means(pickindex);
        end

        letters_picked(s)  = 2*pi ./ (B ./ sqrt(alpha)).^2 * ...
            (log(ecc_0+ecc_max) - log(ecc_0+ecc_min) - ...
            ecc_0 * (ecc_max-ecc_min) / ((ecc_0+ecc_max)*(ecc_0+ecc_min)));

        if contains('within_subjects',factors_to_boot)
            areas_picked(s) = randn * area_std(pickindex) + area_means(pickindex);
        else
            areas_picked(s) = area_means(pickindex);
        end

    end
    conservation = areas_picked \ letters_picked;
    % find number of letters preficted by conservation
    pred = areas_picked .* conservation;
    % find how much variance is explained by conservation
    r2 = R2(letters_picked, pred);

    conservation_to_save(x) = 1/sqrt(conservation);
    alpha_to_save(x) = alpha;
    phi_to_save(x) = ecc_0;
    r2_to_save(x) = r2;

end

sgtitle(sprintf('Nboot = %i [%i-%i deg] V%i',nboots,ecc_min,ecc_max,roi))
subplot(2,2,1)
histogram(conservation_to_save)
ylim([0 nboots/10])
yy = ylim;
hold on
plot([median(conservation_to_save) median(conservation_to_save)],[0 yy(2)],'linewidth',2)
title(sprintf('median \\itc\\rm\\bf = %.2f',mean(conservation_to_save)),'FontSize',20)
xlabel('c')
set(gca,'Fontsize',20)

subplot(2,2,2)
histogram(r2_to_save)
xlabel('r2')
set(gca,'Fontsize',20)
ylim([0 nboots/10])
xlim([-1 1])
hold on
plot([median(r2_to_save) median(r2_to_save)],[0 yy(2)],'linewidth',2)
title(sprintf('median \\itr^2\\rm\\bf = %.2f',median(r2_to_save)),'FontSize',20)
subplot(2,2,3)
histogram(phi_to_save)
xlabel('phi zero')
set(gca,'Fontsize',20)
ylim([0 nboots/10])


subplot(2,2,4)
histogram(alpha_to_save)
xlabel('alpha')
set(gca,'Fontsize',20)
ylim([0 nboots/10])
set(gcf,'Position',[510   386   797   631])



CI_range = 68;
low_prct_range = (100-CI_range)/2;
high_prct_range = 100-low_prct_range;

CI_c=prctile(conservation_to_save, [low_prct_range, high_prct_range]);
CI_r=prctile(r2_to_save, [low_prct_range, high_prct_range]);


fprintf('c = %.2f [%.2f-%.2f]\n',median(conservation_to_save),CI_c(1),CI_c(2));
fprintf('r2 = %.2f [%.2f-%.2f]\n',median(r2_to_save),CI_r(1),CI_r(2));

function out_R2 = R2(data, pred)
% formula for coefficient of variation, R2, which ranges from -inf to 1
% R2 = @(data, pred) 1 - sum((pred-data).^2) / sum((data - mean(data)).^2);

out_R2 = 1 - sumsqr(pred-data) / sumsqr(data - mean(data));

end
