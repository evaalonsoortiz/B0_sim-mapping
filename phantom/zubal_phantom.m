% Zubal phantom
 
% generate susceptibility distribution for my modified Zubal phantom
zubal_sus_dist = Zubal('/Users/mac/Documents/MATLAB/zubal_EAO.nii');
% save as nifti
zubal_sus_dist.save('zubal_EAO_sus.nii');
 
% compute deltaB0 for the simulated Zubal susceptibility distribution 
zubal_dBz = FBFest( zubal_sus_dist.volume, zubal_sus_dist.image_res, zubal_sus_dist.matrix, 'Zubal' );
% save as nifti
zubal_dBz.save('zubal_EAO_dBz.nii'); % zubal_dBz units : ppm
 
%% for loop initialisation
list_SNR = 100:10:300; %[50 75 100 125 linspace(150,500,8)];% linspace(100,500,17); %  get different SNR
% initialisation of the error vectors
mean_rel_error_dual = [];
mean_rel_error_multi = [];
mean_abs_error_dual = [];
mean_abs_error_multi = [];

for k = 1 : length(list_SNR)

fprintf('Calculating SNR %u...\n', list_SNR(k)); tic
% simulate T2* decay for a modified Zubal phantom with a
% deltaB0 found in an external file
% multi-echo
m_zubal_vol = NumericalModel('Zubal','/Users/mac/Documents/MATLAB/zubal_EAO.nii');
m_zubal_vol.generate_deltaB0('load_external', 'zubal_EAO_dBz.nii');
m_zubal_vol.simulate_measurement(4, [0.00126 0.00253 0.00368 0.00488 0.00603 0.00722], list_SNR(k));
% dual-echo
d_zubal_vol = NumericalModel('Zubal','/Users/mac/Documents/MATLAB/zubal_EAO.nii');
d_zubal_vol.generate_deltaB0('load_external', 'zubal_EAO_dBz.nii');
d_zubal_vol.simulate_measurement(15, [0.00238 0.00476], list_SNR(k));

 
% get magnitude and phase data
% multi-echo
m_magn = m_zubal_vol.getMagnitude;
m_phase = m_zubal_vol.getPhase;
m_compl_vol = m_magn.*exp(1i*m_phase);
% dual-echo
d_magn = d_zubal_vol.getMagnitude;
d_phase = d_zubal_vol.getPhase;
d_compl_vol = d_magn.*exp(1i*d_phase);
 
% calculate the deltaB0 map from the magnitude and phase data
[multi_echo_delf] = +imutils.b0.multiecho_linfit(m_compl_vol, [0.00126 0.00253 0.00368 0.00488 0.00603 0.00722]); 
[dual_echo_delf] = +imutils.b0.dual_echo(d_compl_vol(:,:,:,:), [0.00238 0.00476]);

% conversion to ppm
dual_echo_b0_ppm = 1e6*(dual_echo_delf/3)*(1/42.58e6);
multi_echo_b0_ppm = 1e6*(multi_echo_delf/3)*(1/42.58e6);
 
% save b0 maps
nii_vol = make_nii(dual_echo_b0_ppm);
save_nii(nii_vol, ['dualechoB0_ppm_zubal' '.nii']);
 
nii_vol = make_nii(multi_echo_b0_ppm);
save_nii(nii_vol, ['multiechoB0_ppm_zubal' '.nii']);
 
 
%% calculate the error
% 'meanvalue_and_niftifile' or 'meanvalue' or 'niftifile' for
% percent_err_fct and abs_err_fct

% conversion of the simulated volume to ppm 
ppm_zubal_volume = zubal_dBz.volume .* 1e6;

% mean relative error
[percent_diff_dual] = percent_err_fct('PFC_mask_2.nii.gz', dual_echo_b0_ppm, ppm_zubal_volume, 'meanvalue_and_niftifile', 'percent_dual_diff');
mean_rel_error_dual = [mean_rel_error_dual, percent_diff_dual];
 
[percent_diff_multi] = percent_err_fct('PFC_mask_2.nii.gz', multi_echo_b0_ppm, ppm_zubal_volume, 'meanvalue_and_niftifile', 'percent_multi_diff');
mean_rel_error_multi = [mean_rel_error_multi, percent_diff_multi];

% mean absolute error
[abs_diff_dual] = abs_err_fct('Prefrontal_new_mask.nii.gz', dual_echo_b0_ppm, ppm_zubal_volume, 'meanvalue_and_niftifile', 'abs_dual_diff');
mean_abs_error_dual = [mean_abs_error_dual, abs_diff_dual];
 
[abs_diff_multi] = abs_err_fct('Prefrontal_new_mask.nii.gz', multi_echo_b0_ppm, ppm_zubal_volume, 'meanvalue_and_niftifile', 'abs_multi_diff');
mean_abs_error_multi = [mean_abs_error_multi, abs_diff_multi];
 
toc
end

%% Plot the error for different SNR
 
figure(1);
hold on
plot(list_SNR, mean_rel_error_dual, 'Color', 'b', 'Marker', 'o', 'LineWidth',1.5, 'LineStyle','-')
plot(list_SNR, mean_rel_error_multi, 'Color', 'r', 'Marker', 'o', 'LineWidth',1.5, 'LineStyle','-')
legend1 = legend('dual-echo', 'multi-echo');
set(legend1,'Location','best');
title({'SNR variation'},{'Mean relative error from 100 to 300 '})
xlabel('SNR')
ylabel('relative error [%]')
grid on
hold off 

figure(2);
hold on
plot(list_SNR, mean_abs_error_dual, 'Color', 'b', 'Marker', 'o', 'LineWidth',1.5, 'LineStyle','-')
plot(list_SNR, mean_abs_error_multi, 'Color', 'r', 'Marker', 'o', 'LineWidth',1.5, 'LineStyle','-')
legend2 = legend('dual-echo', 'multi-echo');
set(legend2,'Location','best');
title({'SNR variation'},{'Mean absolute error from 100 to 300 '})
xlabel('SNR')
ylabel('absolute error [ppm]')
grid on
hold off
 
 
% % plot results
% figure
% imagesc(squeeze(multi_echo_b0_ppm(:,:,64)))
% colorbar
% title('multi-echo fit: b0 (ppm)')
% 
% figure
% imagesc(squeeze(dual_echo_b0_ppm(:,:,64)))
% colorbar
% title('dual-echo fit: b0 (ppm)')
% 
% figure
% imagesc(squeeze(1e6.*real(zubal_dBz.volume(:,:,64))))
% colorbar
% title('Fourier-based field estimation for the modified Zubal phantom: b0 (ppm)')
% 
% % calc diff between dual-echo and multi-echo
% diff_dualecho = (dual_echo_b0_ppm-1e6.*real(zubal_dBz.volume));
% figure; imagesc(squeeze(diff_dualecho(:,:,64))); colorbar; title('dual echo - true dBz');
% 
% diff_multiecho = (multi_echo_b0_ppm-1e6.*real(zubal_dBz.volume));
% figure; imagesc(squeeze(diff_multiecho(:,:,64))); colorbar; title('multi echo - true dBz');
 
 

% 
% B0_hz = 500;
% TE = [0.0015 0.0025];
% % a = NumericalModel('Shepp-Logan2d', 256);
% % a = NumericalModel('Shepp-Logan3d', 256);
% % a = NumericalModel('Cylindrical3d',128,1,5,90,'air', 'silicone_oil');
% a = NumericalModel('Spherical3d',128,1,5,'air', 'silicone_oil');
% a.generate_deltaB0('2d_linearIP', [B0_hz 0]); 
% figure; imagesc(a.deltaB0),colorbar; title('delta B_0');
% 
% a.simulate_measurement(15, TE, 100);
% 
% phaseMeas = a.getPhase();
% phaseTE1 = squeeze(phaseMeas(:,:,1,1));
% phaseTE2 = squeeze(phaseMeas(:,:,1,2));
% 
% B0_meas = (phaseTE2(:, :) - phaseTE1(:, :))/(TE(2) - TE(1));
% B0_meas_hz = B0_meas/(2*pi);
% figure; imagesc(B0_meas_hz), title('B0_{z}');