clc
clear
close all
obs = {'wlsubj045';'wlsubj117'}

cmap = round([[182 83 159];[238 44 123];[182 83 159];[238 44 123]]/255,2)
sess = [-0.3 0.9 -0.9 0.3]
style = {'-';'-';'-';'-'}


for o = 1 : length(obs)
    close all
    clear h
    if o == 2
        cmap = round([[182 83 159];[238 44 123];[182 83 159];[238 44 123]]/255,2)
    else
        cmap = round([[29 117 188];[25 186 185];[29 117 188];[25 186 185]]/255,2)
    end
    d = dir(sprintf('./data/*%s*',obs{o}));
    figure(o)
    for ses = 1:4

        data = load([d(ses).folder filesep d(ses).name])

        for thr =  1 : length(data.oo)
            
            eccen_x = data.oo(thr).eccentricityXYDeg(1)
            eccen_y = data.oo(thr).eccentricityXYDeg(2)
            spacing = data.oo(thr).spacingDeg

            if eccen_x ~= 0

                myline = [eccen_x - spacing eccen_x + spacing]
                h(ses)= plot(myline,[sess(ses) sess(ses)],'Color',cmap(ses,:),'LineWidth',3,'Linestyle',style{ses})
                hold on

            elseif eccen_y ~= 0
                

                myline = [eccen_y - spacing eccen_y + spacing]
                plot([sess(ses) sess(ses)],myline,'Color',cmap(ses,:),'LineWidth',3,'Linestyle',style{ses})



            end

            %         if obs_data(s,:).("Eccen_X,") > 0
            %
            %             myline = [obs_data(s,:).("Eccen_X,") - obs_data(s,:).spacing obs_data(s,:).("Eccen_X,") + obs_data(s,:).spacing  ]
            %             plot(myline,[0 0])
            %             hold on
            %         end
        end

    end
    axis image
    
hh = plotrings
h =cat(2,h,hh)

ylim([-15.5 15.5])
xlim([-15.5 15.5])
box off
xlabel('Horizontal eccentricity')
ylabel('Vertical eccentricity')
xticks([-15 -10 -5 0 5 10 15])
yticks([-15 -10 -5 0 5 10 15])
set(gca, 'FontSize', 15)

% if o == 1
legend(h([1 2 5 6]),{'Session 1';'Session 2';'5º';'10º'},'box','off')
% end
    g = gca;
    g.YAxis.LineWidth = 1;
    g.XAxis.LineWidth = 1;
    g.XColor = [0 0 0];
    g.YColor = [0 0 0];
    g.Color = 'None'
    hgexport(gcf, sprintf('./figures/crowding_dist_%s.eps',obs{o}));

end


function [h] = plotrings
ct = 1
for ri = [5 10]
    
    r = abs(ri);
    r(r==0) = [];
    if isempty(r)
        
        r = 1
        
    end
    
    th = 0:pi/50:2*pi;
    xunit = r * cos(th)+0;
    yunit = r * sin(th)+0;
    
    
    h(ct) = plot(xunit, yunit,':k','Linewidth',2); hold on
    h(ct).Color(4) = 0.15;
    ct = ct + 1
    
end
end