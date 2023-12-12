clc
clear
close all;

%simulate some data with R2 = 0.43
varexpl = 0.43;
session1 = copularnd('Gaussian',sqrt(varexpl),49);

%create session2 which is session 1 + independent noise for each variable
%lets assume column 1 is bouma and column 2 is area
session2 = zeros(size(session1));
session2(:,1) = session1(:,1);
session2(:,2) = session1(:,2);

session1 = session1';
session2 = session2';

%craete our variables (rows are test-retest)
bouma = [session1(1,:);session2(1,:)];
area =  [session1(2,:);session2(2,:)];

boot_observers = 1; % if zero it bootstraps from test-retest
% we can either bootstrap observers or bootstrap from test-retest

R2(session1(1,:)',session1(2,:)')

%%
if boot_observers
    factors_to_boot = {'across_subjects'};
else
    factors_to_boot = {'within_subjects'};
end

% create means for distributions 
bouma_means = mean(bouma);
area_means = mean(area);

% create stds for distributions
bouma_std = std(bouma);
area_std = std(area);

area_means = area_means';
bouma_means = bouma_means';

% estimate slope and r2 when using mean values from test-retest [NO
% BOOSTRAPPING]

conservation_main = area_means \ bouma_means;
pred = area_means .* conservation_main;
r2_main = R2(bouma_means, pred)


%%
bouma_picked = NaN(length(bouma_means),1);
areas_picked = NaN(length(bouma_means),1);
n_obs = length(bouma_means);
nboots = 10000;
conservation_to_save = NaN(1,nboots);
r2_to_save = NaN(1,nboots);

%create a function that will randomly pick a subject
choose = @(samples) samples(randi(numel(samples)));

% bootstrap!

for x = 1 : nboots


    % if across subjects [pick one subject until 49 subjects are picked]
    % if wihin observers [pick all subjects in the same orded as originally
    % but sample bouma and area from their test-retest distributions


    for s = 1 : n_obs

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

        bouma_picked(s)  = B;

        if contains('within_subjects',factors_to_boot)
            areas_picked(s) = randn * area_std(pickindex) + area_means(pickindex);
        else
            areas_picked(s) = area_means(pickindex);
        end
    end

    conservation = areas_picked \ bouma_picked;
    % find number of letters preficted by conservation
    pred = areas_picked .* conservation;
    % find how much variance is explained by conservation
    r2 = R2(bouma_picked, pred);

    conservation_to_save(x) = 1/sqrt(conservation);
    r2_to_save(x) = r2;

end

subplot(2,2,1)
histogram(conservation_to_save)
ylim([0 nboots/10])
yy = ylim;
hold on
plot([median(conservation_to_save) median(conservation_to_save)],[0 yy(2)],'linewidth',2)
title(sprintf('median \\itc\\rm\\bf = %.2f [noboot = %.2f]',mean(conservation_to_save),conservation_main),'FontSize',20)
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
title(sprintf('median \\itr^2\\rm\\bf = %.2f [noboot = %.2f]',median(r2_to_save),r2_main),'FontSize',20)


set(gcf,'Position',[74    99   959   682])




CI_range = 95;
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


