function [mean_percent_diff] = zubal_err_fct(mask_fname, meas_b0_map_fname, sim_b0_map_fname, varargin)
%
% zubal_err_fct computes the percent difference between two images (meas_b0_map and sim_b0_map) for a certain mask. 
% The percent difference between meas_b0_map and sim_b0_map is calculated pixel-wise within the ROI
%
% _SYNTAX_
% 
% [mean_percent_diff] = zubal_err_fct(mask_fname, meas_b0_map_fname, sim_b0_map_fname, varargin)
%
% _DESCRIPTION_
%
% _INPUT ARGUMENTS_
%
%    mask_fname
%      file name for your mask, must be a string
%
%    meas_b0_map_fname
%      measured 3D data set which represent the field map of a particular method.
%      (dual echo or multi echo)
%
%    sim_b0_map_fname
%      complex 4D data set for the simulated/true magnetic field 
%
%    varargin
%      you can choose between 'meanvalue_and_niftifile', 'meanvalue' and 'niftifile'
%       - 'meanvalue' will compute the mean of the relative error for the whole data set
%       - 'niftifile' will compute the relative error for every element in the
%          data set and will give you a nifti image
%       - 'meanvalue_and_niftifile' will do both
%
% _OUTPUTS_
%
%    mean_percent_diff
%         &/or
%      nifti file
%  
% 
 
mask = niftiread(mask_fname);  % load mask 
mask(mask==0) = NaN; % replace all zeros by NaN
[h_mask, w_mask ,s_mask] = size(mask); % get the dimension 
[h_sim, w_sim, s_sim] = size(sim_b0_map_fname); 
mask_dBz = mask .* 1e6 .* real(sim_b0_map_fname); % 
mask_method = mask .* meas_b0_map_fname; % ROI for dual or multi echo
 
% check that mask and data_vol are the same dimensions
if h_mask ~= h_sim && w_mask ~= w_sim && s_mask ~= s_sim
    error(sprintf('\n Mask file dimensions do not match simulated B_0 data file. \n')); 
end
 
% calculating the relative error (3D data set)
percent_diff = abs((mask_dBz - mask_method)./mask_dBz)*100;  
 
switch varargin{1}
    
    case 'meanvalue'
        
        mean_percent_diff = nanmean(percent_diff, 'all');
 
    case 'niftifile'
        
        nii_vol = make_nii(percent_diff);
        save_nii(nii_vol, [varargin{2} '.nii']);
        
    case 'meanvalue_and_niftifile' 
        
        nii_vol = make_nii(percent_diff);
        save_nii(nii_vol, [varargin{2} '.nii']);
        mean_percent_diff = nanmean(percent_diff, 'all');
 
    otherwise
        
        error_message = 'error in the number of input \n';
        error( 'u:stuffed:it' , error_message );
        
end
end
 

