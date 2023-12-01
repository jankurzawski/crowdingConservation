function [surface_size] = load_surface(datadir,surfaceType,Researcher,hemi)




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
