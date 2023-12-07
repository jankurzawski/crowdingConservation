clc
clear
close all


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

extract_both_sessions = 1;
[bouma, area] = load_from_raw('midgray',[ecc_min ecc_max],extract_both_sessions);

n_obs = size(area,2);
bouma_means = mean(bouma);
bouma_std = std(bouma);

area_means = mean(area);
area_std = std(area);


%%




ecc_0 = 0.24;
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

for x = 1 : nboots

    % for one iteration pick alpha and ecc_0
    alpha   = randn * alpha_std + alpha_mean;
    ecc_0   = randn * phi_std + phi_mean;

    % for each subject pick bouma, and surface area based on the
    % distributions
    for s = 1 : n_obs

        B                  = randn * bouma_std(s) + bouma_means(s);
        B                  = B ./ sqrt(alpha);

        letters_picked(s)  = 2*pi ./ B.^2 * ...
        (log(ecc_0+ecc_max) - log(ecc_0+ecc_min) - ...
        ecc_0 * (ecc_max-ecc_min) / ((ecc_0+ecc_max)*(ecc_0+ecc_min)));
        areas_picked(s) = randn * area_std(s) + area_means(s);

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


% subplot(2,10,e)
% histogram(conservation_to_save)
% ylim([0 nboots/10])
% yy = ylim;
% hold on
% plot([median(conservation_to_save) median(conservation_to_save)],[0 yy(2)],'linewidth',2)
% text(median(conservation_to_save)+0.15*median(conservation_to_save),yy(2) - 0.2*yy(2),sprintf('median \\itc\\rm =%.2f',median(conservation_to_save)),'FontSize',15)
% xlabel('c')


c_boot_mean(e) = mean(conservation_to_save)
c_boot_se(e) = std(conservation_to_save)

r2_boot_mean(e) = mean(r2_to_save)
r2_boot_se(e) = std(r2_to_save)
% set(gca,'Fontsize',20)
leg{e} = sprintf('[%i-%i deg]',ecc_min,ecc_max)

end

subplot(1,2,1)
errorbar(1:length(c_boot_mean),c_boot_mean,c_boot_se)
xticks(1:20)
xticklabels(leg)
hold on
s =plot(xlim,[1.4 1.4],'--')
legend(s,'Our estimate')



subplot(1,2,2)
errorbar(1:length(r2_boot_mean),r2_boot_mean,r2_boot_se)
xticks(1:20)
xticklabels(leg)
hold on
s =plot(xlim,[0.4 0.4],'--')
legend(s,'Our estimate')
% subplot(2,2,2)
% histogram(r2_to_save)
% xlabel('r2')
% set(gca,'Fontsize',20)
% ylim([0 nboots/10])
% 
% subplot(2,2,3)
% histogram(phi_to_save)
% xlabel('phi zero')
% set(gca,'Fontsize',20)
% ylim([0 nboots/10])
% 
% subplot(2,2,4)
% histogram(alpha_to_save)
% xlabel('alpha')
% set(gca,'Fontsize',20)
% ylim([0 nboots/10])


function out_R2 = R2(data, pred)
% formula for coefficient of variation, R2, which ranges from -inf to 1
% R2 = @(data, pred) 1 - sum((pred-data).^2) / sum((data - mean(data)).^2);

out_R2 = 1 - sumsqr(pred-data) / sumsqr(data - mean(data));

end
