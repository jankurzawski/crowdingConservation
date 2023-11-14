clc
clear
% This script computes the relationship between surface area and number of
% letters with the assumption that conservation holds. It finds the best
% fitting constant of proportionality and asks how much variance in the
% psychophysical data (number of letters) is explained by a simple scaling
% of the surface area.
nboot = 1000;
[bouma, area] = crowding_summary_data();
load ../extra/mycmap.mat

% set this to true if you want to get a sense of null distributions: it
% shuffles the assignment of psychophysical data to brain data
doshuffle = false;

% lower case letters for linear units
a = area';
b = bouma'; clear area bouma;
n = length(b);

if doshuffle, b = b(randperm(n)); end

% compute number of lettrs from bouma
l = zeros(size(b));

for i = 1 : length(b)
    analytic = crowding_count_letters(b(i),0.24,10,0);
    l(i) = analytic;
    axis off
end

% upper case for log units
A = log(a);
B = log(b);
L = log(l);

% linear case
% l = k * a;
% => k = a \ l;

% log case
% L = K + A;
% => K = L - A

% find linear and log constants, k and K
for ii = 4:-1:1
    k(ii) = a(:,ii) \ l;
    K(ii) = mean(L - A(:,ii));
end

% predicted number of letters assuming to conservation
pred = a * diag(k);
PRED = K + A;


% formula for coefficient of variation, R2, which ranges from -inf to 1
% R2 = @(data, pred) 1 - sum((pred-data).^2) / sum((data - mean(data)).^2);

% Plot the  fits
ROIs = {'V1' 'V2' 'V3' 'hV4'};


CI_range = 68;
low_prct_range = (100-CI_range)/2;
high_prct_range = 100-low_prct_range;

CI_a_save = NaN(2,4);
CI_r2 = NaN(nboot,4);
convervation = NaN(4,1);
kk = NaN(1,4);
myr2 = NaN(4,1);

for plots = 1:2
    figure();clf
    set(gcf, 'color','w', 'Position', [400 400 500 700]); tiledlayout(2,2,'TileSpacing','compact');
    
    for ii = 1:4
        nexttile
        
        switch plots
            case 1 % log
                r2 = R2(L, PRED(:,ii));                
                c = exp(K(ii));
                str = 'log';
                xl = [min(a(:,ii))*.5 max(a(:,ii))*1.05];
                yl = [xl(1)*c max(l)*1.05];
                lm = fitlm(A(:,ii),L);
                lmpred = lm.Coefficients.Estimate(1)+ lm.Coefficients.Estimate(2)*log(xl);
                lmpred = exp(lmpred);
                
                data = [A(:,ii) L PRED(:,ii)];
                fitresult_ls = bootstrp(nboot,@give_a_b_r,data);

            case 2 % linear
                r2 = R2(l, pred(:,ii));
                myr2(ii) = r2;
                c  = k(ii);
                str = 'linear';
                xl = [0 max(a(:,ii))*1.05];
                yl = [0 max(l)*1.05];
                
                lm = fitlm(a(:,ii),l);
                kk(ii) = lm.Coefficients.Estimate(2);
                lmpred = lm.Coefficients.Estimate(1)+ lm.Coefficients.Estimate(2)*xl;
                
                data = [a(:,ii) l pred(:,ii)];
                fitresult_ls = bootstrp(nboot,@give_a_b_r,data);
                                               
                
        end

        
        CI_a=prctile(fitresult_ls(:,2), [low_prct_range, high_prct_range]);
        CI_b=prctile(fitresult_ls(:,1), [low_prct_range, high_prct_range]);
        CI_a_save(:,ii) = CI_a;
        CI_r2(:,ii)=fitresult_ls(:,3);

        
        X = linspace(min(a(:,ii)),max(a(:,ii)),100);
        
        y = zeros(100,nboot);
        
        for i = 1:nboot
            
            y(:,i)=fitresult_ls(i,2)*X + fitresult_ls(i,1);
            
        end
        
        
        CI_y=prctile(y, [low_prct_range, high_prct_range],2);
        
        set(gca, 'FontSize', 15, 'XScale', str, 'YScale', str)
        fprintf('V%d, %s: R^2=%3.2f\tK = %3.2f letters/m^2\n', ii, str, r2, c)
        
        axis([xl yl])
        
        hold on,
        plot(xl, c * xl, 'k--', 'LineWidth', 1)
        convervation(ii) = c;
        plot(xl, lmpred, '-', 'Color', mycmap{ii}(2,:), 'LineWidth', 3);
        plot(X,CI_y,'--','linewidth',2,'Color', mean(mycmap{ii}))
        g = gca;
        g.XAxis.LineWidth = 1;
        g.YAxis.LineWidth = 1;
        s = scatter(a(:,ii), l,  'MarkerFaceColor',mycmap{ii}(2,:), 'MarkerEdgeColor', 'k');
        s.MarkerFaceAlpha = 1;
        s.MarkerEdgeColor = mycmap{ii}(2,:);
        s.SizeData = 20;
        
        s_ex = scatter(a([2 9],ii), l([2 9]), 'MarkerFaceColor','k', 'MarkerEdgeColor', 'k');

        hold off
        title(ROIs{ii})
        myx = xlim;
        text(min(a(:,ii))+0.03*myx(2),100,sprintf('R^2 = %.2f',median(CI_r2(:,ii))),'FontSize',12,'FontWeight','bold','horizontalalignment','left','Color',[0 0 0])

        if ii == 1
            xticks([0 2000 4000])
            
        elseif ii == 2
            xticks([0 1500 3000])
            
        elseif ii == 3
            xticks([0 1250 2500])
        elseif ii == 4

            xticks([0 750 1500])
        end

    end
    
    %     hgexport(gcf, sprintf('../figures/conservation_fit_%s.eps', str));
    
end

set(gcf, 'color','w', 'Position', [400 400 500 700]);

figure();clf
set(gcf, 'color','w', 'Position', [400 400 500 700]);

subplot(2,2,4)
xs = [1 2 3 4];


CI_r=prctile(CI_r2, [low_prct_range, high_prct_range]);
mymedian = mean(CI_r);
CI_r2_r = abs(CI_r - mymedian);

for r = 1 : 4
    color = mean(mycmap{r});
    hold on
    b =  bar(xs(r), myr2(r),'FaceColor',[0 0 0],'Edgecolor',[0 0 0],'LineWidth',2);
    er = errorbar(xs(r), myr2(r),CI_r2_r(1,r),CI_r2_r(2,r),'linestyle','--','Color',[0.5 0.5 0.5],'LineWidth',4,'CapSize',0);

end

xticks(xs)
ylim([-0.3  0.6])
yticks([-0.2 0 0.2 0.4 0.6 0.8])

xticklabels(ROIs)
set(gca,'Fontsize',18);
g = gca;
g.XAxis.Color = [0 0 0];
g.YAxis.Color = [0 0 0];

xlim([0 4.5])

plot(xlim,[0 0],'--','LineWidth',2,'Color',[0 0 0])

box off


g = gca;
g.YAxis.LineWidth = 1;
g.XAxis.LineWidth = 1;


figure();clf
set(gcf, 'color','w', 'Position', [400 400 500 700]); tiledlayout(2,2,'TileSpacing','compact');
hold on
conservation_dat = [kk;k];

xs = [1 2 3 4;
   0.8 1.8 2.8 3.8];

CI_kk = abs(CI_a_save - kk);


for r = 1 : 4
    
    color = [mean(mycmap{r});[0 0 0]];
    
    for p = 1 : 2
        
        if p == 1
            er = errorbar(xs(p,r),conservation_dat(p,r),CI_kk(1,r),CI_kk(2,r),'Color',mycmap{r}(1,:),'LineWidth',2,'CapSize',0);
                        plot(xs(p,r),conservation_dat(p,r),'.','MarkerSize',20,'Color',mycmap{r}(2,:))

            hold on 
        else  
            text(xs(p,r),conservation_dat(p,r),'C','FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle','FontName','Sloan','Color',[0 0 0])
        end
    end
end

xticks([1 2 3 4])
ylim([-0.1 0.8])

xticklabels(ROIs)
set(gca,'Fontsize',18);
xlim([0 4.5])
% plot(xlim,[0 0],'--','LineWidth',2,'Color',[0 0 0])

box off
ylabel('Slope')

set(gcf,'Position',[396   537   420   576])

g = gca;
g.YAxis.LineWidth = 1;
g.XAxis.LineWidth = 1;


function [fitresults] = give_a_b_r(data)

lm = fitlm(data(:,1),data(:,2));
r2 = R2(data(:,2),data(:,3));

fitresults = [lm.Coefficients.Estimate(1) lm.Coefficients.Estimate(2) r2];

end


function out_R2 = R2(data, pred)

out_R2 = 1 - sum((pred-data).^2) / sum((data - mean(data)).^2);

end

