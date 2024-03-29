function num_letters = crowding_count_letters(B, ecc_0, ecc_max, ecc_min, B_orientation)
% compute number of letters that fit in a circular aperture centered at
%  fixation given Bouma's law and threshold spacing
%
% The Bouma factor, B, can be radial, tangential, or the geometric mean of
% the two, as specified by B_orientation, which can be 'r', 't', 'm'. By
% default, we assume B is radial. When counting letters in the 2D visual
% field, we use a formula that is derived from a 2D integral in polar
% coordinates. The formula assumes that the Bouma factor is the geometric
% mean of radial and tangential. For simplicity, we assume that the
% radial-to-tangenial ratio is 2, as commonly measured. Hence if the input
% is radial, we divide by sqrt(2). If the input is tangential, we multiply
% by sqrt(2). 
% 
% 
% Example using default parameters:
%  num_letters = crowding_count_letters
%
% Example varying Bouma factor
%  Bs = linspace(.1, .5, 100)
%  for ii = 1:length(Bs)
%    num_letters(ii) = crowding_count_letters(Bs(ii));
%  end
% subplot(211); plot(Bs, num_letters, 'x-'); xlabel('Bouma factor'); ylabel('Number of letters');
% subplot(212); plot(Bs, 1./sqrt(num_letters), 'x-'); xlabel('Bouma factor'); ylabel('1/sqrt(number of letters)');
%
% for forumla, see: 
%   https://www.symbolab.com/solver/integral-calculator/%5Cint_%7Bm%7D%5E%7Bn%7D%20%5Cint_%7B0%7D%5E%7B2%5Cpi%7D%20%5Cfrac%7Br%7D%7BB%5E%7B2%7D%5Cleft(r%2B%5Cphi%5Cright)%5E%7B2%7D%7D%20d%5Ctheta%20dr?or=input
%
% for reduced formula, assuming ecc_max=10, ecc_min=0, alpha=2, phi0=0.24,
%   and radial bouma factor, the function reduces to L=34.89/B^2:
%   https://www.symbolab.com/solver/integral-calculator/2%5Cint_%7B0%7D%5E%7B10%7D%20%5Cint_%7B0%7D%5E%7B2%5Cpi%7D%20%5Cfrac%7Br%7D%7BB%5E%7B2%7D%5Cleft(r%2B0.24%5Cright)%5E%7B2%7D%7D%20d%5Ctheta%20dr?or=input
%   
% See also crowding_Visualize_Letters

if ~exist('ecc_max', 'var') || isempty(ecc_max), ecc_max  = 10;   end
if ~exist('ecc_min', 'var') || isempty(ecc_min), ecc_min  = 0;    end
if ~exist('ecc_0', 'var')   || isempty(ecc_0),   ecc_0    = 0.24; end
if ~exist('B', 'var')       || isempty(B),       B        = 0.2;  end
if ~exist('B_orientation', 'var') || isempty(B_orientation), B_orientation = 'r';  end

switch lower(B_orientation)
    case 'r', B = B / sqrt(2);
    case 't', B = B * sqrt(2);
    case 'm' % do nothing
end

num_letters = 2*pi ./ B.^2 * ...
    (log(ecc_0+ecc_max) - log(ecc_0+ecc_min) - ...
    ecc_0 * (ecc_max-ecc_min) / ((ecc_0+ecc_max)*(ecc_0+ecc_min)));

end