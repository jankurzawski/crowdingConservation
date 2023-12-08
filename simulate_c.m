clc
clear
close all


ecc_max = 10;
ecc_min = 0;

[bouma, area] = load_from_raw('midgray',1);

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


for x = 1 : nboots
    
    % for one iteration pick alpha and ecc_0
    
    
    % for each subject pick bouma, and surface area based on the
    % distributions
    
  
  
    
    for s = 1 : n_obs
        
%           alpha   = randn * alpha_std + alpha_mean;
          alpha   = 2;
%           ecc_0   = randn * phi_std + phi_mean;
          ecc_0   = 0.24;
          
          while ecc_0 < 0

              ecc_0   = randn * phi_std + phi_mean;
          end


        pickindex          = choose(1:length(bouma_means));
        
%         B                  = randn .* bouma_std(pickindex) + bouma_means(pickindex);
        B                  = bouma_means(pickindex);
        B                  = B ./ sqrt(alpha);
        
        letters_picked(s)  = 2*pi ./ B.^2 * ...
            (log(ecc_0+ecc_max) - log(ecc_0+ecc_min) - ...
            ecc_0 * (ecc_max-ecc_min) / ((ecc_0+ecc_max)*(ecc_0+ecc_min)));
        
       
%         areas_picked(s) = randn * area_std(pickindex) + area_means(pickindex);
        areas_picked(s) = area_means(pickindex);
        
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

sgtitle(sprintf('Nboot = %i [%i-%i deg]',nboots,ecc_min,ecc_max))
subplot(2,2,1)
histogram(conservation_to_save)
ylim([0 nboots/10])
yy = ylim;
hold on
plot([mean(conservation_to_save) mean(conservation_to_save)],[0 yy(2)],'linewidth',2)
text(mean(conservation_to_save)+0.1*mean(conservation_to_save),yy(2) - 0.2*yy(2),sprintf('mean \\itc\\rm =%.2f',mean(conservation_to_save)),'FontSize',20)
xlabel('c')
set(gca,'Fontsize',20)

subplot(2,2,2)
histogram(r2_to_save)
xlabel('r2')
set(gca,'Fontsize',20)
ylim([0 nboots/10])
hold on
plot([median(r2_to_save) median(r2_to_save)],[0 yy(2)],'linewidth',2)
text(median(r2_to_save)+0.15*median(r2_to_save),yy(2) - 0.2*yy(2),sprintf('mean \\itr\\rm =%.2f',median(r2_to_save)),'FontSize',20)
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


function out_R2 = R2(data, pred)
% formula for coefficient of variation, R2, which ranges from -inf to 1
% R2 = @(data, pred) 1 - sum((pred-data).^2) / sum((data - mean(data)).^2);

out_R2 = 1 - sumsqr(pred-data) / sumsqr(data - mean(data));

end
