function [counted, analytic,letters] = crowding_Visualize_Letters(B, alpha, ecc_0, ecc_max, ecc_min,plots, B_orientation)
%Make a display of Sloan letters spaced according to Bouma's law.
%
% Inputs
%   B: Bouma factor. Default = 0.3
%   alpha: Radial:Tangential crowding ratio. Default = 2
%   ecc_0: negative x-intercept of crowding distance vw eccentricity.
%       Default = 0.2
%   ecc_max: maximum eccentricity in degrees. Default = 10
%   ecc_min: minimum eccentricity in degrees. Default = 0.2
%   plots: 0 means no plots, just return values; 1 means plot letters; 2
%           means plot letters and gratings. Default = 1;
%       
%
% Example 1 (default parameters):
%    crowding_Visualize_Letters();
%
% Example 2 (vary Bouma)
%   crowding_Visualize_Letters(0.2);
%   crowding_Visualize_Letters(0.4);
%
% Example 3 (vary alpha)
%   crowding_Visualize_Letters([], 1);
%   crowding_Visualize_Letters([], 2);
%
% See also crowding_count_letters
%
% References
%       Anstis (1974, Vis Res) for analogous display wrt size
%       Intrilligator and Cavanagh (2001, Cog Psych) for attentional
%       resolution chart (figure 14)

% Crowding parameters, from: spacing = (ecc_0 + r) * B * alpha
if ~exist('B', 'var')     || isempty(B), B = 0.3; end
if ~exist('alpha', 'var') || isempty(alpha), alpha = 2; end
if ~exist('ecc_0', 'var') || isempty(ecc_0), ecc_0 = 0.24; end
if ~exist('B_orientation', 'var') || isempty(B_orientation), B_orientation = 'r';  end

switch lower(B_orientation)
    case 'r', B = B / sqrt(alpha);
    case 't', B = B * sqrt(alpha);
    case 'm' % do nothing
end

% Display parameters
if ~exist('ecc_max', 'var') || isempty(ecc_max), ecc_max = 10; end
if ~exist('ecc_min', 'var') || isempty(ecc_min), ecc_min = .5; end

if ~exist('plots', 'var') || isempty(plots), plots = 1; end
if ~exist('rightVFonly', 'var') || isempty(rightVFonly), rightVFonly = 1; end

if ecc_0 == 0 && ecc_min == 0
    error('Either the miminum eccentricity, min_ecc, or the negative x-intercept, ecc_0, must be greater than 0.')
end

if ecc_min >= ecc_max
    error('The minimum eccentricity must be less than the maximum')
end

% maximum eccentriciy cannot be greater than 90 deg
ecc_max = min(ecc_max, 900); 

num_px  = ecc_max*1000;

% Make cartesian and polar grids
[x, y] = meshgrid(linspace(-ecc_max,ecc_max,num_px));
[th, r] = cart2pol(x,y);

% The radial and tangential Bouma factors are scaled up/down by sqrt alpha
B_radial     = B * sqrt(alpha);
B_tangential = B / sqrt(alpha);


% This is the key calculation. We make gratings along the radial and
% tangential axes, with the local period (1/frequency) matched to the
% spacing. We offset the phase with a random number. This is not strictly
% necessary, but the number of letters that fit in the display can vary
% abruptly with simulation parameters due to edge effects, and the random
% phase offset prevents this. Note the local frequency is the derivative of
% local phase, and the derivatives of these expressions should give the
% reciprical of spacing. 
offset              = pi/2 - (2*pi/B_radial * log(10+ecc_0));
phase_radial        = 2*pi/B_radial * log(r+ecc_0)+offset;      % phase for annuli (along radial axis)
phase_tangential    = 2*pi/B_tangential*th.* r./(r+ecc_0);  % phase for pinwheels (around circle)
annuli              = sin(phase_radial);
pinwheels           = sin(phase_tangential);

% crop outside display limits
annuli(r>ecc_max | r<ecc_min)    = 0;
pinwheels(r>ecc_max | r<ecc_min) = 0;

% By summing the radial and tangential patterns, we get a plaid which
% incorporates spacing in both radial and tangential directions
plaid       = annuli+pinwheels;

% Find the peaks of the plaid. This is where we will display letters.
BW = imregionalmax(plaid);
inds = find(BW);

% Remove letters that are very close to the inner or outer edge of the
% display to avoid artifacts
% BAD = r(inds)/ecc_max>.99 | r(inds)/ecc_min<1.01;
% inds = inds(~BAD);

counted = length(inds);
analytic = crowding_count_letters(B, ecc_0, ecc_max, ecc_min, 'm');



% Specificy letter locations, font size, and character 
letters.x = x(inds);
letters.y = y(inds);
[letters.th, letters.r] = cart2pol(letters.x, letters.y);
letters.font_size = letters.r/ecc_max * 35 +ecc_min/4;
letters.Sloan = {'D' 'H' 'K' 'N' 'O' 'R' 'S' 'V' 'Z'};
letters.char = letters.Sloan(randi(9, [length(inds) 1])); 

% remove letters for readability
letters.char(letters.th < deg2rad(-45)) = {''};
letters.char(letters.th > deg2rad(45)) = {''};
letters.char(letters.r < 1) = {''};


if plots == 0, return; end

% letters.
% Plot them
for fig_num = 1:plots
    figure; set(gcf, 'Position', [0+1000*(fig_num-1) 1 1200 1200])

    % show the underlying plaid pattern
    switch fig_num
        case 1
            p = polaraxes(); p.RLim = [0 ecc_max];
            a = letters.th; b = letters.r;
        case 2
            imagesc([-ecc_max ecc_max], [-ecc_max ecc_max], plaid);
            axis equal; axis(ecc_max*[-1 1 -1 1]); colormap gray;
            a = letters.x; b = letters.y;
    end

    hold on,

    % show letters at grating peaks
    t = text(a, b, letters.char, 'FontName','Sloan', 'HorizontalAlignment','center');               

    % scale the font size 
    for ii = 1:length(letters.th), t(ii).FontSize = letters.font_size(ii); end
    
    % add a fixation
    text(0, 0, '+', 'FontSize',20, 'HorizontalAlignment','center','VerticalAlignment','middle');

    % Plot title
    str = sprintf('Bouma factor: %2.2f; Radial/Tangential ratio: %2.1f\nTotal number of letters from %3.2fº to %3.2fº: %d (analytic) %d (counted)', ...
        B, alpha, ecc_min, ecc_max, round(analytic), counted);
     title(str, 'FontSize',18)
    
end