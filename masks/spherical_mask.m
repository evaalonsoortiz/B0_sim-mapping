function mask = spherical_mask(radius, volDimensions, res)
% Create a spherical mask.
%
% _SYNTAX_
% 
%
% _DESCRIPTION_
% The mask is a matrix which has the desired dimensions with zeros
% everywhere except in a centered ball with the desired radius
%
% _INPUT ARGUMENTS_
%    radius
%      The radius of the ball
%    volDimensions
%      The dimensions of the volume. The length of volDimensions has to be
%      3.
%    res
%      Object resolution.  The length of res has to be 3.
%
% _OUTPUTS_
%    mask
%      The mask created, with the dimensions specified in volDimensions.
%
%_EXAMPLE_
% 
% Code created for https://github.com/evaalonsoortiz/B0_sim-mapping/


% define image grid
[x,y,z] = ndgrid(linspace(-(volDimensions(1)-1)/2,(volDimensions(1)-1)/2,volDimensions(1)),linspace(-(volDimensions(2)-1)/2, (volDimensions(2)-1)/2, volDimensions(2)), linspace(- (volDimensions(3)-1) /2, (volDimensions(3)-1)/2, volDimensions(3) ) );

% radial position (in [mm])
r = sqrt((x .* res(1)).^2 + (y .* res(2)).^2 + (z .* res(3)).^2);

mask = zeros(volDimensions(1), volDimensions(2), volDimensions(3));

mask(r <= radius ) = 1;
mask(r > radius ) = 0;

end