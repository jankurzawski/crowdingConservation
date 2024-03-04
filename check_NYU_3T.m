clc
clear

BIDS = '/Volumes/server/Projects/Retinotopy_NYU_3T/';

roi_dir = '/Volumes/server/Projects/Retinotopy_NYU_3T/derivatives/ROI_mgz/'
fs_dir = '/Volumes/server/Projects/Retinotopy_NYU_3T/derivatives/freesurfer/'

s_NYU = dir(sprintf('%s/*sub*',roi_dir));
s_NYU = {s_NYU.name}
s_NYU(1) = [];
        hemi = {'lh';'rh'}

for s = 1 : length(s_NYU)

    for roi = 1 : 4



        for h = 1:2

            tmp_roi = MRIread(sprintf('%s/%s/%s.ROIs_V1-4.mgz',roi_dir,s_NYU{s},hemi{h}));
            tmp_surf = read_curv(sprintf('%s/%s/surf/%s.area.mid',fs_dir,s_NYU{s},hemi{h}));

            area(h) = sum(tmp_surf(tmp_roi.vol == roi));

        end

        v4_nyu.area(s,roi) = sum(area);
        v4_nyu.subj(s) = s_NYU(s);
    end

end

%%
BIDS = '/Volumes/server/Projects/hv4/';
roi_dir = '/Volumes/server/Projects/hv4/derivatives/ROI_mgz_V1-V4/';
fs_dir = '/Volumes/server/Projects/hv4/derivatives/freesurfer/';

s_NEI = dir(sprintf('%s/*sub*',fs_dir));
s_NEI = {s_NEI.name};

ind = contains(s_NEI,'sub-wlsubj162');
s_NEI(ind) = [];
ind = contains(s_NEI,'sub-wlsubj153');
s_NEI(ind) = [];


for s = 1 : length(s_NEI)

    for roi = 1 : 4

        for h = 1:2

            tmp_roi1 = MRIread(sprintf('%s/Jan_%s.%s.ROIs_V1-4.mgz',roi_dir,hemi{h},s_NEI{s}));
            tmp_surf1 = read_curv(sprintf('%s/%s/surf/%s.area.mid',fs_dir,s_NEI{s},hemi{h}));

            tmp_roi2 = MRIread(sprintf('%s/Brenda_%s.%s.ROIs_V1-4.mgz',roi_dir,hemi{h},s_NEI{s}));
            tmp_surf2 = read_curv(sprintf('%s/%s/surf/%s.area.mid',fs_dir,s_NEI{s},hemi{h}));


           
            r1 = sum(tmp_surf1(tmp_roi1.vol == roi));
            r2 = sum(tmp_surf2(tmp_roi2.vol == roi));

             area(h) = r2;
        end

        v4_nei.area(s,roi) = sum(area);
        v4_nei.subj(s) = s_NEI(s);
    end


end

%%

figure(1);clf
% ind = contains(v4_nei.subj,'sub-wlsubj135')
% v4_nei.subj(ind) = [];


for roi = 1 : 4
subplot(2,2,roi)

ct = 1
for s = 1 : length(v4_nei.subj)

    if sum(ismember(v4_nyu.subj,v4_nei.subj{s})) == 1

        v4_nei_area(ct) = v4_nei.area(s,roi)
        v4_nyu_area(ct) = v4_nyu.area(find(ismember(v4_nyu.subj,v4_nei.subj{s})),roi)
        subj{ct} = v4_nei.subj{s}
        ct = ct + 1;
    end
end




scatter(v4_nei_area',v4_nyu_area','filled');
xlabel('nei_area','Interpreter','none')
ylabel('nyu_area','Interpreter','none')
hold on


for s = 1 : length(subj)

    text(v4_nei_area(s),v4_nyu_area(s),subj{s})

end

title(sprintf('V%i R = %.2f',roi,corr(v4_nei_area',v4_nyu_area')))

axis equal
plot(xlim,ylim,'--')
%%

end
return
addpath(genpath('data'))
addpath(genpath('code'))
addpath(genpath('extra'))
ROIs = {'V1' 'V2' 'V3' 'hV4'};
load mycmap


load subjects_ID.mat
two_sess = 0;
[bouma, area] = load_from_raw('midgray',0,[0 10]);

%%

ct = 1
for s = 1 : length(subj)

    if sum(ismember(subjects,subj{s})) == 1
        bouma_nyu(ct) = bouma(find(ismember(subjects,subj{s})))
        l(ct) =  crowding_count_letters(bouma_nyu(ct),0.24,10,0);
        ct = ct + 1
    end
end


conservation = v4_nyu_area' \ l';
% find number of letters preficted by conservation
pred = v4_nei_area' .* conservation;
% find how much variance is explained by conservation
r2 = R2(l, pred)





function out_R2 = R2(data, pred)
% formula for coefficient of variation, R2, which ranges from -inf to 1
% R2 = @(data, pred) 1 - sum((pred-data).^2) / sum((data - mean(data)).^2);

out_R2 = 1 - sumsqr(pred-data) / sumsqr(data - mean(data));

end


