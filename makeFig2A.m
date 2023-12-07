clc
clear
close all


[directory,~] = fileparts(mfilename('fullpath'));
cd(directory);
addpath(genpath('code'));
addpath(genpath('data'));
addpath(genpath('extra'));

obs = {'wlsubj045';'wlsubj117'}

cmap = round([[182 83 159];[238 44 123];[182 83 159];[238 44 123]]/255,2);
sess = [0.45 -0.45 0.15 -0.15];
style = {'-';'-';'-';'-'};


for o = 1 : length(obs)
    figure(o)
    clear h
    if o == 2
        cmap = round([[182 83 159];[238 44 123];[182 83 159];[238 44 123]]/255,2);
    else
        cmap = round([[29 117 188];[25 186 185];[29 117 188];[25 186 185]]/255,2);
    end
    d = dir(sprintf('./data/crowdingData/*%s*',obs{o}));
    figure(o);
    for ses = 1:4

        data = load([d(ses).folder filesep d(ses).name]);

        for thr =  1 : length(data.oo)

            eccen_x = data.oo(thr).eccentricityXYDeg(1);
            eccen_y = data.oo(thr).eccentricityXYDeg(2);
            spacing = data.oo(thr).spacingDeg;

            if eccen_x ~= 0

                myline = [eccen_x - spacing eccen_x + spacing];
                h(ses)= plot(myline,[sess(ses) sess(ses)],'Color',cmap(ses,:),'LineWidth',3,'Linestyle',style{ses});
                hold on

            elseif eccen_y ~= 0


                myline = [eccen_y - spacing eccen_y + spacing];
                plot([sess(ses) sess(ses)],myline,'Color',cmap(ses,:),'LineWidth',3,'Linestyle',style{ses});



            end
                        s=scatter(eccen_x,eccen_y,15,[0 0 0],'filled');

        end

    end
    axis image

    text(sqrt(5),5,'5º')
    text(sqrt(10),10,'10º')
    
    
    hh = plotrings(cmap(1,:));
    h =cat(2,h,hh,s);
    ylim([-15.5 15.5]);
    xlim([-15.5 15.5]);
    box off
    xlabel('Horizontal eccentricity');
    ylabel('Vertical eccentricity');
    xticks([-15 -10 -5 0 5 10 15]);
    yticks([-15 -10 -5 0 5 10 15]);
    set(gca, 'FontSize', 15);

    legend(h([1 2 7]),{'Session 1';'Session 2';'target location'},'box','off');
    g = gca;
    g.YAxis.LineWidth = 1;
    g.XAxis.LineWidth = 1;
    g.XColor = [0 0 0];
    g.YColor = [0 0 0];
    g.Color = 'None';

    hgexport(gcf, sprintf('./figures/crowding_dist_%s.eps',obs{o}));

end


function [h] = plotrings(mycmap)
ct = 1;
for ri = [5 10]

    r = abs(ri);
    r(r==0) = [];
    if isempty(r)

        r = 1;

    end

    th = 0:pi/50:2*pi;
    xunit = r * cos(th)+0;
    yunit = r * sin(th)+0;


    h(ct) = plot(xunit, yunit,':k','Linewidth',2); hold on
    h(ct).Color(4) = 0.15;
    ct = ct + 1;

    plot([-0.5 0.5],[0 0],'Color',mycmap,'LineStyle','-','LineWidth',2);
    plot([0 0],[-0.5 0.5],'Color',mycmap,'LineStyle','-','LineWidth',2);


end
end