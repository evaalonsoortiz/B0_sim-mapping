% SNR

%% Brain
echo1 = double(niftiread('/Users/mac/Desktop/NeuroPoly/Data EAO/Brain/dcm_gre_fm_TW_TRIGGER_100sli_2mm_20200113163813_13_e1.nii'));
% figure; imagesc(squeeze(echo2(:,:,55))); colorbar; title('echo1');
echo2 = double(niftiread('/Users/mac/Desktop/NeuroPoly/Data EAO/Brain/dcm_gre_fm_TW_TRIGGER_100sli_2mm_20200113163813_13_e2.nii'));
% figure; imagesc(squeeze(echo2(:,:,55))); colorbar; title('echo2');
mask_SNR_pfc = double(niftiread('/Users/mac/Desktop/NeuroPoly/Data EAO/Brain/mask_SNR_pfc.nii'));
mask_SNR_noise = double(niftiread('/Users/mac/Desktop/NeuroPoly/Data EAO/Brain/mask_SNR_noise.nii'));

% region of interest, (inside the PFC and outside the head, 3D) 
ROI_tissue_brain_e1 = mask_SNR_pfc .* echo1;
ROI_tissue_brain_e2 = mask_SNR_pfc .* echo2;
ROI_noise_brain_e1 = mask_SNR_noise .* echo1;
ROI_noise_brain_e2 = mask_SNR_noise .* echo2;

% SNR mean
%snr_mean_e1 = nanmean(ROI_e1, 'all')./(sqrt(2/pi) .* nanmean(NOISE_e1, 'all'));
snr_mean_brain_e1 = mean(nonzeros(ROI_tissue_brain_e1))./(sqrt(2/pi) .* mean(nonzeros(ROI_noise_brain_e1)));
%snr_mean_e2 = nanmean(ROI_e2, 'all')./(sqrt(2/pi) .* nanmean(NOISE_e2, 'all'));
snr_mean_brain_e2 = mean(nonzeros(ROI_tissue_brain_e2))./(sqrt(2/pi) .* mean(nonzeros(ROI_noise_brain_e2)));

snr_mean_brain_m = (snr_mean_brain_e1 + snr_mean_brain_e2)/2

% SNR stdv
snr_stdv_brain_e1 = mean(nonzeros(ROI_tissue_brain_e1))./(sqrt(2/(4-pi)) .* std(nonzeros(ROI_noise_brain_e1)));
snr_stdv_brain_e2 = mean(nonzeros(ROI_tissue_brain_e2))./(sqrt(2/(4-pi)) .* std(nonzeros(ROI_noise_brain_e2)));

snr_stdv_brain_m = (snr_stdv_brain_e1 + snr_stdv_brain_e2)/2


%% Torso

% Magnitude
torso_1 = double(niftiread('/Users/mac/Desktop/NeuroPoly/Data EAO/Torso/20211029.acdc_149.21.10.29_17_19_18_DST_1.3.12.2.1107.5.2.43.167006_gre_field_mapping_PMUlog_20211029172808_4.nii'));
% Phase
torso_2 = double(niftiread('/Users/mac/Desktop/NeuroPoly/Data EAO/Torso/20211029.acdc_149.21.10.29_17_19_18_DST_1.3.12.2.1107.5.2.43.167006_gre_field_mapping_PMUlog_20211029172808_5_e2_ph.nii'));

[a, b, c, d] = size(torso_1);

% Region of interest, (inside the SC and outside the torso, 2D)
ROI_tissue_torso = zeros(a,b,c,d);
ROI_tissue_torso(42:52,75:105,:,:) = 1;
% ROI signal tissue
ROI_tissue_torso = ROI_tissue_torso(:,:,:,:).*torso_1(:,:,:,:);

ROI_noise_torso = zeros(a,b,c,d);
ROI_noise_torso(11:17,50:60,:,:) = 1;
% ROI background noise
ROI_noise_torso = ROI_noise_torso(:,:,:,:) .* torso_1(:,:,:,:);


%image
figure; 
imagesc(ROI_noise_torso(:,:,1,1) + ROI_tissue_torso(:,:,1,1) + torso_1(:,:,1,1)); colormap;

% SNR diff
snr_diff_torso_e1 = 1/sqrt(2).*(mean(nonzeros(ROI_tissue_torso(:,:,1,1) + ROI_tissue_torso(:,:,1,3))))...
    ./(std(nonzeros(ROI_tissue_torso(:,:,1,1) - ROI_tissue_torso(:,:,1,3))));
snr_diff_torso_e2 = 1/sqrt(2).*(mean(nonzeros(ROI_tissue_torso(:,:,1,2) + ROI_tissue_torso(:,:,1,6))))...
    ./(std(nonzeros(ROI_tissue_torso(:,:,1,2) - ROI_tissue_torso(:,:,1,6))));

snr_diff_torso_m = (snr_diff_torso_e1 + snr_diff_torso_e2)/2 

% SNR mean
snr_mean_torso_e1 = mean(nonzeros(ROI_tissue_torso(:,:,1,1)))./(sqrt(2/pi) .* mean(nonzeros(torso_1(11:17,44:67,1,1))));
snr_mean_torso_e2 = mean(nonzeros(ROI_tissue_torso(:,:,1,2)))./(sqrt(2/pi) .* mean(nonzeros(torso_1(11:17,44:67,1,2))));

snr_mean_brain_m = (snr_mean_torso_e1 + snr_mean_torso_e2)/2 

% SNR stdv
snr_stdv_torso_e1 = mean(nonzeros(ROI_tissue_torso(:,:,1,1)))./(sqrt(2/(4-pi)) .* std(nonzeros(torso_1(11:17,44:67,1,1))));
snr_stdv_torso_e2 = mean(nonzeros(ROI_tissue_torso(:,:,1,2)))./(sqrt(2/(4-pi)) .* std(nonzeros(torso_1(11:17,44:67,1,2))));

snr_stdv_brain_m = (snr_stdv_torso_e1 + snr_stdv_torso_e2)/2 

