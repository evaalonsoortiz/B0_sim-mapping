function [mean_rel_error_method] = zubal_err_fct(mask_file_name, method, mag_field_sim, plane, cross_sect)
%
% zubal_err_fct computes the mean relative error for a certain mask in the zubal
% phantom. First, the mask is applied on the true magnetic field and on the
% method you chose. Then, we substract the B0 map created from your method
% and the true magnetic field and finally we divide this operation with 
% the true magnetic (element by element). If you have a 3D data set 
% (256x256x128), you have to choose a plane in the matrix, the first 
% dimension is for the sagital plane, the second dimension is for the
% coronal plane and the third dimension is for the axial plane. You'll now
% have a 2D data set containing the relative error for each element of your
% matrix. We calculate the mean value of the 2D data set and the output 
% is the mean relative error for a specify plane and cross section.
%
% _SYNTAX_
% 
% [mean_rel_error_method] = err_fct(mask_file_name, method, mag_field_sim, plane, cross_sect)
%
% _DESCRIPTION_
%
% _INPUT ARGUMENTS_
%
%    mask_file_name
%      file name for your mask, must be a string
%
%    method
%      real 3D data set which represent the field map of a particular method.
%      (dual echo or multi echo)
%
%    mag_field_sim
%      complex 4D data set for the true magnetic field 
%
%    plane
%      choose the axis/plane you want 
%      'sagital' 
%      'coronal'
%      'axial'
%
%    cross_sect
%      choose where you want to cut in the plane
%
%
% _OUTPUTS_
%
%    mean_rel_error_method 
%      mean relative error for a specify plane and cross section
% 
%
% _EXAMPLE_
% 
%  [err_dual] = zubal_err_fct('zubal_mask.nii.gz', dual_echo_b0_ppm, zubal_dBz.volume, 'sagital', 128);
%  


% get the error in a particular region for the zubal phantom (sinuses)
mask = niftiread(mask_file_name);  % mask in the sinuses
[dim1, dim2 ,dim3] = size(mask);
mask_dBz = mask .* 1e6 .* real(mag_field_sim); % ROI for the real magnetic field
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

