function [bouma, area] = crowding_summary_data()

% Bouma factos are RADIAL
load('bouma_factors', 'bouma_S1', 'bouma_S2');
bouma = geomean([bouma_S1 bouma_S2]'); % geometric mean across test/retest

% Surface area is mm^s per hemisphere for V1-V4
load('surface_size', 'researcher1', 'researcher2');
r1 = sum(researcher1, 3); % sum across hemispheres
r2 = sum(researcher2, 3); % sum across hemispheres
area =  (r1+r2)/2; % average across researchers

end
