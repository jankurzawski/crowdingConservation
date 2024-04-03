clc
clear
close all

[directory,~] = fileparts(mfilename('fullpath'));
cd(directory);
addpath(genpath('data'))
addpath(genpath('code'))
addpath(genpath('extra'))
ROIs = {'V1' 'V2' 'V3' 'V4'};
load mycmap

two_sess = 0;
[bouma, area] = load_from_raw('midgray',two_sess);
ROIs = {'V1' 'V2' 'V3' 'hV4'};


YData = crowding_count_letters(bouma,0.24,10,0);
sdy = std(YData);
Y = YData/sdy;
yl = [0 1400]/sdy;
ytl = 0:300:1200;
yt = ytl/sdy;


figure (101); clf; set(gcf, 'Color', 'w')
t=tiledlayout(2,3,"TileSpacing","compact");
tilenums = [1 2 4 5];
R = [];
numboot = 500;

plotidx = [1 2 4 5];
for ii = 1:4
    XData = area(:,ii);
    sdx = std(XData);
    X = XData/sdx;

    mx = max(X*1.1);
    xl = [0 10];
    dx = round(mx*sdx/3,-2);
    xtl = (1:3)*dx;
    xt = xtl /sdx;
    



    R(:,ii)  = bootstrp(numboot, @corr, X, Y);
    R2(:,ii) = bootstrp(numboot, @conservationR2, X, Y);
    
    conservation = bootstrp(numboot, @mldivide, X, Y);
    x = linspace(0,mx);
    pred = conservation*x;
    CI = prctile(pred, [16 84]);
    med = prctile(pred, 50);


    nexttile(tilenums(ii));
    hold on;
    plot(x, CI, 'k:', 'LineWidth',1)
    plot(x, med, 'k--', 'LineWidth',2)
    plotErrorEllipse(mean([X Y]), cov([X Y]), .68,  mycmap{ii}(2,:), ':');
    plotErrorEllipse(mean([X Y]), cov([X Y]), .95,  mycmap{ii}(2,:), '--');
    plot(X, Y, 'o', 'MarkerSize', 6, 'MarkerFaceColor', mycmap{ii}(2,:), ...
        'MarkerEdgeColor', 'none'); hold on
    axis equal; axis([xl yl]);
    box off
    set(gca, 'FontSize', 16)
    set(gca, 'YTick', yt, 'YTickLabel', ytl, 'XTick', xt, 'XTickLabel', xtl);
    title(ROIs{ii})
    xlabel('Surface area (mm^2)')
    ylabel('Number of letters \lambda')
end
%%
nexttile(3)
bar(mean(R), 'k'); ylim([-.2 1])
hold on;
errorbar(mean(R), std(R), '-', 'Color', .5*[1 1 1], 'LineWidth', 3, 'LineStyle','none')
set(gca, 'XTick', 1:4, 'XTickLabel', ROIs, 'FontSize', 16)
ylabel('Pearson''s r')
title(sprintf('Correlation between\n\\lambda and surface area'))
box off

nexttile(6)
bar(mean(R2), 'k'); ylim([-.4 .6])
hold on;
errorbar(mean(R2), std(R2), '-', 'Color', .5*[1 1 1], 'LineWidth', 3, 'LineStyle','none')
set(gca, 'XTick', 1:4, 'XTickLabel', ROIs, 'FontSize', 16)
title(sprintf('Accuracy in predicting\n\\lambda from conservation line'))
ylabel('R^2 ')
set(gca, 'YTick', [-.2:.2:.4]);
box off

set(gcf,'Position',[   367   127   828   689])
hgexport(gcf, sprintf('./figures/Figure3.eps'));


function plotErrorEllipse(mu, Sigma, p, color, linespec)

if ~exist('color', 'var'), color = []; end
if ~exist('linespec', 'var'), linespec = []; end

s = -2 * log(1 - p);

[V, D] = eig(Sigma * s);

t = linspace(0, 2 * pi);
a = (V * sqrt(D)) * [cos(t(:))'; sin(t(:))'];

plot(a(1, :) + mu(1), a(2, :) + mu(2), linespec, 'Color', color, 'LineWidth',1);

end

function R2 = conservationR2(X, Y)
m = mldivide(X, Y);
pred = m * X;
R2 = 1 - sumsqr(pred-Y) / sumsqr(Y - mean(Y));
end