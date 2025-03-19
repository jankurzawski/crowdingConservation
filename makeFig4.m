
clear
close all

[directory,~] = fileparts(mfilename('fullpath'));
cd(directory);
addpath(genpath('data'))
addpath(genpath('code'))
addpath(genpath('extra'))
ROIs = {'V1' 'V2' 'V3' 'V4'};
load mycmap

% load data
two_sess = 1;

[bouma, area] = load_from_raw([],two_sess);

lambda_one = crowding_count_letters(bouma(1,:),0.24,10,0);
lambda_two = crowding_count_letters(bouma(2,:),0.24,10,0);
lambda_R = corr(lambda_one',lambda_two');
figure (102); clf; set(gcf, 'Color', 'w')
t2=tiledlayout(1,2,"TileSpacing","compact");

nexttile(1)
scatter(lambda_one,lambda_two,20,repmat([0 0 0],[size(area(2,1,:),3) 1]),'filled','MarkerFaceAlpha',0.8)

hold on;
ylabel(sprintf('\\it\\lambda\\rm from session 2'))
xlabel(sprintf('\\it\\lambda\\rm from session 1'))
% ylim([-0.5 1])
ylim([0 1500])
xlim([0 1500])
myleg_l = sprintf('\\it r \\rm =  %.2f',lambda_R)
h = plot(1000,1000,'.','Color','w')
plot(xlim,ylim,'--','Color',[0 0 0])

legend(h,myleg_l,'Location','southeast')
legend box off

g = gca;
g.YAxis.Color = [0 0 0];
g.XAxis.Color = [0 0 0];
g.LineWidth = 1;
load mycmap
box off
axis square
set(gca, 'FontSize', 15)

nexttile(2)
hold on;

for r = 1 : 4

h(r)=scatter(squeeze(area(1,r,:)),squeeze(area(2,r,:)),20,repmat([mycmap{r}(2,:)],[size(area(2,r,:),3) 1]),'filled','MarkerFaceAlpha',0.6)
R(r) = corr(squeeze(area(1,r,:)),squeeze(area(2,r,:)));

myleg{r} = sprintf('%s, \\it r \\rm =  %.2f',ROIs{r},R(r))

end
ylabel(sprintf('\\it A\\rm from Researcher 2'))
xlabel(sprintf('\\it A\\rm from Researcher 1'))



g = gca;
g.YAxis.Color = [0 0 0];
g.XAxis.Color = [0 0 0];
g.LineWidth = 1;
box off

ylim([0 4000])
xlim([0 4000])

plot(xlim,ylim,'--','Color',[0 0 0])
l=legend(h,myleg,'Location','southeast');
l.Position = [[0.7726 0.2669 0.2200 0.2439]]
legend box off

set(gca, 'FontSize', 15)

axis square

set(gcf,'Position',[681   581   559   285])

hgexport(gcf, sprintf('./figures/test_retest.eps'));
