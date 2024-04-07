function num_letters = crowding_count_letters(B, ecc_0, ecc_max, ecc_min, B_orientation, alpha)
% compute number of letters that fit in a circular aperture centered at
%  fixation given Bouma's law and threshold spacing
%
% The Bouma factor, B, can be radial, tangential, or the geometric mean of
% the two, as specified by B_orientation, which can be 'r', 't', 'm'. By
% default, we assume B is radial. When counting letters in the 2D visual
% field, we use a formula that is derived from a 2D integral in polar
% coordinates. The formula assumes that the Bouma factor is the geometric
% mean of radial and tangential. Hence if the input is radial, we divide by
% sqrt(alpha). If the input is tangential, we multiply by sqrt(alpha).
% 
%
% 
% Example using default parameters:
%  num_letters = crowding_count_letters()
%
% Example varying Bouma factor
%  Bs = linspace(.1, .5, 100);
%  num_letters = crowding_count_letters(Bs);
% subplot(211); plot(Bs, num_letters, 'x-'); xlabel('Bouma factor'); ylabel('Number of letters');
% subplot(212); plot(Bs, 1./sqrt(num_letters), 'x-'); xlabel('Bouma factor'); ylabel('1/sqrt(number of letters)');
%
% See also crowding_Visualize_Letters

if ~exist('ecc_max', 'var') || isempty(ecc_max), ecc_max  = 10;   end
if ~exist('ecc_min', 'var') || isempty(ecc_min), ecc_min  = 0;    end
if ~exist('ecc_0', 'var')   || isempty(ecc_0),   ecc_0    = 0.24; end
if ~exist('B', 'var')       || isempty(B),       B        = 0.2;  end
if ~exist('alpha', 'var')   || isempty(alpha),   alpha    = 2;    end
if ~exist('B_orientation', 'var') || isempty(B_orientation), B_orientation = 'r';  end

switch lower(B_orientation)
    case 'r', B = B / sqrt(alpha);
    case 't', B = B * sqrt(alpha);
    case 'm' % do nothing
end


syms phi th 

num_letters = int(...
    int( phi./((B.*(phi+ecc_0)).^2), th, 0, 2*pi), ...
    phi, 0, ecc_max);


% To get a numerical output, we cast the output as a double precision integer
num_letters = double(num_letters);

end