function [b0] = dual_echo(complVol, delt)
% dual_echo computes c0 fieldmaps based on complex division of dual-echo
% gradient-echo data
%
% _SYNTAX_
% 
% [b0] = dual_echo(complVol, delt)
%
% _DESCRIPTION_
%
% _INPUT ARGUMENTS_
%
%    compl_vol
%      complex 4D data set complVol(x,y,z,t)
%    delt
%      array of TEs in [s]
%
% _OUTPUTS_
%
%   b0
%     field map in units of Hz 
% 

handedness = 'left'; % Siemens & Canon = 'left', GE & Philips = 'right' 
            
% create magnitude and phase data volumes
mag_data = abs(complVol);
ph_data = angle(complVol);

% ph_data differnece reconstruction: Handbook of MRI pulse sequences S.13.5.1
Z1(:,:,:) = mag_data(:,:,:,1).*exp(1i*ph_data(:,:,:,1));
Z2(:,:,:) = mag_data(:,:,:,2).*exp(1i*ph_data(:,:,:,2));

% pre-allocate memory for variables
dPhi = zeros(size(ph_data,1),size(ph_data,2),size(ph_data,3));
% generate a mask 
sigma = bkgrnd_noise(mag_data);
mask = threshold_masking(mag_data, sigma);

switch handedness
    case 'left'
        for i=1:size(ph_data,1)
            for j=1:size(ph_data,2)
                for k = 1:size(ph_data,3)
                    if (mask(i,j,k) == 0)
                        dPhi(i,j,k) = 0;
                    else
                        dPhi(i,j,k) = atan2(imag(Z2(i,j,k).*conj(Z1(i,j,k))),real(Z2(i,j,k).*conj(Z1(i,j,k))));
                    end
                end
            end
        end

    case 'right'
        for i=1:size(ph_data,1)
            for j=1:size(ph_data,2)
                for k = 1:size(ph_data,3)
                    if (mask(i,j,k) == 0)
                        dPhi(i,j,k) = 0;
                    else
                        dPhi(i,j,k) = atan2(imag(Z1(i,j,k).*conj(Z2(i,j,k))),real(Z1(i,j,k).*conj(Z2(i,j,k))));
                    end
                end
            end
        end
end

% switch handedness
%     case 'left'
%         dPhi(:,:,:) = atan2(imag(Z2(:,:,:).*conj(Z1(:,:,:))),real(Z2(:,:,:).*conj(Z1(:,:,:))));
%     case 'right'
%         dPhi(:,:,:) = atan2(imag(Z1(:,:,:).*conj(Z2(:,:,:))),real(Z1(:,:,:).*conj(Z2(:,:,:))));
% end

b0(:,:,:) = dPhi(:,:,:)./(delt(2)-delt(1)); % [rad*Hz]
b0 = b0/(2*pi); % [Hz]
