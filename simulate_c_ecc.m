clc
clear
close all

[directory,~] = fileparts(mfilename('fullpath'));
cd(directory);
addpath(genpath('data'))
addpath(genpath('code'))
addpath(genpath('extra'))
roi = 4;

  
CI_range = 68;
low_prct_range = (100-CI_range)/2;
high_prct_range = 100-low_prct_range;



for ee = 10:-1:1
    
    eccs(ee,1) = 10;
    eccs(ee,2) = ee-1;
end
eccs1 = eccs(:,[2 1]);


for ee = 1:10
    
    eccs2(ee,1) = 0;
    eccs2(ee,2) = ee;
    
end

eccs = cat(1,eccs2,eccs1);


for e = 1 : size(eccs,1)
    
    
    ecc_max = eccs(e,2);
    ecc_min = eccs(e,1);
    
    
    % factors_to_boot = {'across_subjects';'within_subjects';'alpha';'phi0'};
    factors_to_boot = {'across_subjects'};
    
    
    load_two_sessions = 1;
    [bouma, area] = load_from_raw('midgray',load_two_sessions,[ecc_min ecc_max]);
    
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
        
        % for one iteration pick alpha and ecc_0
        
        
        % for each subject pick bouma, and surface area based on the
        % distributions
        
        
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
            
            if contains('across_subjects',factors_to_boot)
                pickindex          = choose(1:length(bouma_means));
            else
                pickindex = s;
            end
            
            if contains('within_subjects',factors_to_boot)
                B                  = randn .* bouma_std(pickindex) + bouma_means(pickindex);
            else
                B                  = bouma_means(pickindex);
            end
            
            B                  = B ./ sqrt(alpha);
            
            letters_picked(s)  = 2*pi ./ B.^2 * ...
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
    
  
    CI_c=prctile(conservation_to_save, [low_prct_range, high_prct_range]);
    CI_r=prctile(r2_to_save, [low_prct_range, high_prct_range]);
    

    
    c_boot_mean(e) = median(conservation_to_save);
    c_boot_ci(e,:) = abs(CI_c - median(conservation_to_save));

    
    r2_boot_mean(e) = median(r2_to_save);
    r2_boot_ci(e,:) = abs(CI_r - median(r2_to_save));
    
    leg{e} = sprintf('[%i-%i deg]',ecc_min,ecc_max)
    
    
end


%%
figure(1);clf
subplot(1,2,1)
errorbar(1:length(c_boot_mean),c_boot_mean,c_boot_ci(:,1),c_boot_ci(:,2));
xticks(1:20)
xticklabels(leg)
hold on
s =plot(xlim,[1.36 1.36],'--')
legend(s,'Our estimate')

xtickangle(90)

subplot(1,2,2)
errorbar(1:length(r2_boot_mean),r2_boot_mean,r2_boot_ci(:,1),r2_boot_ci(:,2));
xticks(1:20)
xticklabels(leg)
hold on
s =plot(xlim,[0.4 0.4],'--')
legend(s,'Our estimate')
xtickangle(90)

function out_R2 = R2(data, pred)
% formula for coefficient of variation, R2, which ranges from -inf to 1
% R2 = @(data, pred) 1 - sum((pred-data).^2) / sum((data - mean(data)).^2);

out_R2 = 1 - sumsqr(pred-data) / sumsqr(data - mean(data));

end
