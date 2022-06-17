function [percent_diff] = zubal_err_fct(mask_fname, meas_b0_map_fname, sim_b0_map_fname)
%
% zubal_err_fct computes the percent difference between two images (meas_b0_map and sim_b0_map) for a certain mask. 
% The percenct difference between meas_b0_map and sim_b0_map is calculated pixel-wise within the ROI
%
% _SYNTAX_
% 
% [mean_rel_error_method] = zubal_err_fct(mask, meas_b0_map, sim_b0_map)
%
% _DESCRIPTION_
%
% _INPUT ARGUMENTS_
%
%    mask
%      file name for your mask, must be a string
%
%    meas_b0_map
%      measured 3D data set which represent the field map of a particular method.
%      (dual echo or multi echo)
%
%    sim_b0_map
%      complex 4D data set for the simulated/true magnetic field 
%
%
% _OUTPUTS_
%
%    percent_diff 
%  
%

mask = niftiread(mask_fname);  % load mask 
[dim1, dim2 ,dim3] = size(mask);
mask_dBz = mask .* 1e6 .* real(sim_b0_map_fname); % verify units of mag_field_sim and justify conversion
mask_method = mask .* method; % ROI for dual or multi echo

% calculating the efficacity of both methods using the relative error
switch plane
    
    case 'sagital'
        
        for i = 1 : dim2
            for j = 1 : dim3
                if mask_dBz(cross_sect,i,j)==0
                    rel_error_method(i,j) = 0;
                else
                    rel_error_method(i,j) = abs((mask_dBz(cross_sect,i,j) - mask_method(cross_sect,i,j))/...
                                            mask_dBz(cross_sect,i,j)); % relative error  
                end
            end
        end
        mean_rel_error_method = sum(rel_error_method(:,:), 'all')/nnz(mask(cross_sect,:,:));
        
    case 'coronal'
        
        for i = 1 : dim1
            for j = 1 : dim3
                if mask_dBz(i,cross_sect,j)==0
                    rel_error_method(i,j) = 0;
                else
                    rel_error_method(i,j) = abs((mask_dBz(i,cross_sect,j) - mask_method(i,cross_sect,j))/...
                                            mask_dBz(i,cross_sect,j)); % relative error 
                end
            end
        end
        mean_rel_error_method = sum(rel_error_method(:,:), 'all')/nnz(mask(:,cross_sect,:));
        
    case 'axial'
        
        for i = 1 : dim1
            for j = 1 : dim2
                if mask_dBz(i,j,cross_sect)==0
                rel_error_method(i,j) = 0;
                else
                rel_error_method(i,j) = abs((mask_dBz(i,j,cross_sect) - mask_method(i,j,cross_sect))/...
                                        mask_dBz(i,j,cross_sect)); % relative error 
                end
            end
        end
        mean_rel_error_method = sum(rel_error_method(:,:), 'all')/nnz(mask(:,:,cross_sect));
    
    otherwise
        
        error_message = [ 'this plane doesn''t exist.\n',...
                          'The options are : \n',...
                          'sagital\n',...
                          'coronal\n',...
                          'axial\n'];
        error( 'u:stuffed:it' , error_message );
        
end
end

