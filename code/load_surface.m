function [surface_size] = load_surface(datadir,surfaceType,Researcher,hemi)


% this function calculates surfaze size of each area using freesurfer's
% surface area files (*.area.mid, *.area (white) or *.area.pial). Surface
% files are copied directly from freesurfer's surf directory. ROIs are
% created in the same format, have indices from 0 to 4 and are prepared in
% Both can be loaded to freesurfer's read_curv.m function that we include
% under the "extra" folder.


% Indices for ROI files are as follows:
% 0 (undefined)
% 1 (V1)
% 2 (V2)
% 3 (V3)
% 4 (hV4)


for h = 1 : length(hemi)
    
    
    surface_files = dir(sprintf('%s/%s.*%s*',datadir,hemi{h},surfaceType));
    
    for s = 1 : length(surface_files)
        
        ind = strfind(surface_files(s).name,'_');
        subject = surface_files(s).name(ind(1)+1:ind(2)-1);
        
        
        researcher_rois = dir(sprintf('%s/%s.%s*%s',datadir,hemi{h},Researcher,subject));
        surface = read_curv([datadir filesep surface_files(s).name]);
        rois = read_curv([datadir filesep researcher_rois.name]);
        
        for r = 1 : 4
            
        
            surface_size(r,s,h) = sum(surface(rois == r));
            end
            
        end
    end
    
end
