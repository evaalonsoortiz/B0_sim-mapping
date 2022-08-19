addpath 'shim-sim_matlab'
addpath 'shim-sim_matlab/misc'
addpath 'shim-sim_matlab/external/NIFTI'
addpath 'shim-sim_matlab/numerical_model'
addpath 'phantom'
addpath 'masks'

% Complete this path if Fourier-based-field-estimation is not directly 
% in the precedent directory
pathFourier = '../Fourier-based-field-estimation'; 
addpath(pathFourier)
addpath([pathFourier '/utils'])
% Complete this path to add Zubal_EAO file (previously donloaded) to the
% path
%addpath 'Zubal_EAO.nii' 