function mask = cylindrical_mask(radius, theta, volDimensions, res)
% Create a cylindrical mask.
%
% _SYNTAX_
% 
%
% _DESCRIPTION_
% The mask is a matrix which has the desired dimensions with zeros
% everywhere except in a centered cylinder with the desired radius and a
% fixed length
%
% _INPUT ARGUMENTS_
%    radius
%      The radius of the cylinder
%    theta
%      The amgle between the cylinder axis and z-axis (B0) (radians)
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

% in-plane radial position (in [mm])
r = sqrt((x.*res(1)).^2 + (y.*res(2)).^2);

mask = zeros(volDimensions(1), volDimensions(2), volDimensions(3));

mask(r <= radius ) = 1;
mask(r > radius ) = 0;

% rotate distribution about the y-axis
t = [cos(theta)  0      -sin(theta)   0
  0             1              0     0
  sin(theta)    0       cos(theta)   0
  0             0              0     1];
tform = affine3d(t);
mask = imwarp(mask, tform);

end