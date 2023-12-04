function [datatable] = load_crowding(datadir)

% this functions load m-file data saved by CriticalSpacing.m software that
% measures crowding distance.
% (https://github.com/denispelli/CriticalSpacing)

% load_crowding  creates a table summarizing thresholds from all observes.
% There are 4 files per subject (two eccentricities and two sessions). Each
% file contains thresholds measured at 4 cardinal meridians and one
% eccentricity

files = dir(sprintf('%s/*.mat',datadir));
datatable = table();

for f = 1 : length(files)
    
    
    tmp = load(sprintf('%s/%s',datadir,files(f).name));

    for o = 1 : length(tmp.oo)

        eccentricity = sqrt(tmp.oo(o).eccentricityXYDeg(1).^2+tmp.oo(o).eccentricityXYDeg(2).^2);
        
        if tmp.oo(o).eccentricityXYDeg(1) > 0 && tmp.oo(o).eccentricityXYDeg(2) == 0
            
            meridian = 'Right';
            
        elseif tmp.oo(o).eccentricityXYDeg(1) < 0 && tmp.oo(o).eccentricityXYDeg(2) == 0
            
            meridian = 'Left';
            
        elseif  tmp.oo(o).eccentricityXYDeg(1) == 0 && tmp.oo(o).eccentricityXYDeg(2) < 0
            
            meridian = 'Lower';
            
        elseif  tmp.oo(o).eccentricityXYDeg(1) == 0 && tmp.oo(o).eccentricityXYDeg(2) > 0
            
            
            meridian = 'Upper';
            
        end
        
        mytmp_table = table({tmp.oo(o).observer},{tmp.oo(o).flankingDirection},tmp.oo(o).eccentricityXYDeg(1),tmp.oo(o).eccentricityXYDeg(2),eccentricity,tmp.oo(o).spacingDeg,{[tmp.oo(o).trialData.spacingDeg]},{tmp.oo(o).targetFont},{meridian},tmp.oo(o).session,{tmp.oo(o).experiment});
        datatable = cat(1,datatable,mytmp_table);

        
    end
    
end
datatable.Properties.VariableNames = {'Observer';'flankinDirection';'Eccen_X';'Eccen_Y';'RadialEccen';'CrowdingDistance';'QuestStaircase';'Font';'Meridian';'Session';'ExperimentName';};
clearvars -except datatable