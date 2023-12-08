function [bouma, area] = load_from_raw(surfaceType,two_sess)


% this function prepares data for analysis and plotting. It loads the
% datatable created by load_crowding and creates one threshold per observer
% Using load_surface it calculates surface area of visual maps from a
% specified surface (white, midgray, pial) and sums across hemispheres.

[datatable] = load_crowding('./data/crowdingData');
u_ses       = unique(datatable.Session);
u_obs       = unique(datatable.Observer);
bouma_sess  = NaN(length(u_ses),length(u_obs));

assert(length(u_obs) == 49);
assert(sum(datatable.Session == 1) == sum(datatable.Session == 2));

for o = 1 : length(u_obs)

    for s = 1 : length(u_ses)

        sel = contains(datatable.Observer,u_obs{o}) & datatable.Session == s;
        bouma_factors = datatable.CrowdingDistance(sel) ./ datatable.RadialEccen(sel);
        bouma_sess(s,o) = geomean(bouma_factors);

    end
end

if two_sess
    bouma       = bouma_sess;
else
    bouma       = mean(bouma_sess);

end

%%
if ~exist('surfaceType', 'var') || isempty(surfaceType), surfaceType = 'midgray'; end

hemi        = {'lh';'rh'};
% load ROIs from researcher 1
researcher1 = load_surface('./data/surfaceData',surfaceType,'R1',hemi);
% load ROIs from researcher 2
researcher2 = load_surface('./data/surfaceData',surfaceType,'R2',hemi);

r1          = sum(researcher1, 3);   % sum across hemispheres
r2          = sum(researcher2, 3);   % sum across hemispheres
if two_sess

area(1,:) = r1(4,:);
area(2,:) = r2(4,:);

else
area        =  (r1+r2)/2;  
end
% average across researchers

