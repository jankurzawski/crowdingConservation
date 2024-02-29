clc
clear
close all

[directory,~] = fileparts(mfilename('fullpath'));
cd(directory);
addpath(genpath('data'))
addpath(genpath('code'))
addpath(genpath('extra'))
ROIs = {'V1' 'V2' 'V3' 'hV4'};

factors_to_boot = {'across_subjects';'within_subjects'};
% factors_to_boot = {''alpha';'phi0''};

ecc_max = 10;
ecc_min = 0;

load_two_sessions = 1;
[bouma, areas] = load_from_raw('midgray',load_two_sessions,[ecc_min ecc_max]);
CI_range = 68;
low_prct_range = (100-CI_range)/2;
high_prct_range = 100-low_prct_range;
load mycmap

for r = 1 : 4
roi = r;
area = squeeze(areas(:,roi,:));

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

nboots = 1000;

conservation_to_save = NaN(1,nboots);
r2_to_save = NaN(1,nboots);
alpha_to_save = NaN(1,nboots);
phi_to_save =  NaN(1,nboots);

alpha   = 2;
ecc_0   = 0.24;


choose = @(samples) samples(randi(numel(samples)));

if ~exist('factors_to_boot','var'); factors_to_boot = {};end

for x = 1 : nboots

    % for each iteration pick alpha and ecc_0


    for s = 1 : n_obs

        % for each subject pick bouma, and surface area based on the
        % distributions

    
        if contains('across_subjects',factors_to_boot)
            vector = (1:length(bouma_means));
            pickindex = vector(randi(length(vector)));
        else
            pickindex = s;
        end

        if contains('within_subjects',factors_to_boot)

            mycond = randperm(3);
            mycond = mycond(1);

            if mycond == 1

                B = bouma(1,pickindex);

            elseif mycond == 2
                
                B = bouma(2,pickindex);

            elseif mycond == 3

                B = bouma_means(pickindex);

            end

        else
             B = bouma_means(pickindex);
        end

        letters_picked(s)  = 2*pi ./ (B ./ sqrt(alpha)).^2 * ...
            (log(ecc_0+ecc_max) - log(ecc_0+ecc_min) - ...
            ecc_0 * (ecc_max-ecc_min) / ((ecc_0+ecc_max)*(ecc_0+ecc_min)));

        if contains('within_subjects',factors_to_boot)
           
            mycond = randperm(3);
            mycond = mycond(1);

             if mycond == 1

                areas_picked(s) = area(1,pickindex);

            elseif mycond == 2

                areas_picked(s) = area(2,pickindex);

            elseif mycond == 3
                areas_picked(s) = area_means(pickindex);

             end
        else
                areas_picked(s) = area_means(pickindex);


        end

    end
    conservation = areas_picked \ letters_picked;
    % find number of letters preficted by conservation
    pred = areas_picked .* conservation;
    % find how much variance is explained by conservation
    r2 = R2(letters_picked, pred);
    r2_to_save(x) = r2;

end



myr2(r) = median(r2_to_save);
CI_r2_vals=prctile(r2_to_save, [low_prct_range, high_prct_range]);
CI_r2_toplot(r,:) = abs(CI_r2_vals -  median(r2_to_save));

end

%%

figure(1);clf
set(gcf, 'color','w', 'Position', [900   400   500   700]);

subplot(2,2,4)
xs = [1 2 3 4];


for r = 1 : 4
    
    color = mean(mycmap{r});
    hold on
    b =  bar(xs(r), myr2(r),'FaceColor',[0 0 0],'Edgecolor',[0 0 0],'LineWidth',2);
    er = errorbar(xs(r), myr2(r),CI_r2_toplot(r,1),CI_r2_toplot(r,2),'linestyle','--','Color',[0.5 0.5 0.5],'LineWidth',4,'CapSize',0);
    
end

xticks(xs)
ylim([-0.4  0.6])
yticks([-0.2 0 0.2 0.4 0.6 0.8])

xticklabels(ROIs)
set(gca,'Fontsize',15);
xlim([0 4.5])
box off
g = gca;
g.YAxis.LineWidth = 0.5;
g.XAxis.LineWidth = 0.5;
g.XColor = [0 0 0];
g.YColor = [0 0 0];

hgexport(gcf, sprintf('./figures/variance_expl.eps'));





function out_R2 = R2(data, pred)
% formula for coefficient of variation, R2, which ranges from -inf to 1
% R2 = @(data, pred) 1 - sum((pred-data).^2) / sum((data - mean(data)).^2);

out_R2 = 1 - sumsqr(pred-data) / sumsqr(data - mean(data));

end
