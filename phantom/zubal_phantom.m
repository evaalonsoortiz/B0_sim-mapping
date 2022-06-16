% Zubal phantom

% generate susceptibility distribution for my modified Zubal phantom
zubal_sus_dist = Zubal('/Users/mac/Documents/MATLAB/zubal_EAO.nii');
% save as nifti
zubal_sus_dist.save('zubal_EAO_sus.nii');

% compute deltaB0 for the simulated Zubal susceptibility distribution 
zubal_dBz = FBFest( zubal_sus_dist.volume, zubal_sus_dist.image_res, zubal_sus_dist.matrix, 'Zubal' );
% save as nifti
zubal_dBz.save('zubal_EAO_dBz.nii');

% first we store the real part of the magnetic field simulation
real_mag = real(zubal_dBz.volume);

%% for loop initialisation
list_SNR = linspace(0,300,21); % get different SNR
% initialisation of the error vector
mean_rel_error_dual = [];
mean_rel_error_multi = [];

for k = 1 : length(list_SNR)
    
fprintf('Calculating SNR %u...\n', list_SNR(k)); tic

% simulate T2* decay for a modified Zubal phantom with a
% deltaB0 found in an external file
zubal_vol = NumericalModel('Zubal','/Users/mac/Documents/MATLAB/zubal_EAO.nii');
zubal_vol.generate_deltaB0('load_external', 'zubal_EAO_dBz.nii');
zubal_vol.simulate_measurement(15, [0.001 0.002 0.003 0.004 0.005 0.006], list_SNR(k));


% get magnitude and phase data zubal
magn = zubal_vol.getMagnitude;
phase = zubal_vol.getPhase;
compl_vol = magn.*exp(1i*phase);


% calculate the deltaB0 map from the magnitude and phase data
[dual_echo_delf] = +imutils.b0.dual_echo(compl_vol(:,:,:,1:2), [0.001 0.002]);
[multi_echo_delf] = +imutils.b0.multiecho_linfit(compl_vol, [0.001 0.002 0.003 0.004 0.005 0.006]); 

dual_echo_b0_ppm = 1e6*(dual_echo_delf/3)*(1/42.58e6);
multi_echo_b0_ppm = 1e6*(multi_echo_delf/3)*(1/42.58e6);

% save b0 maps
nii_vol = make_nii(dual_echo_b0_ppm);
save_nii(nii_vol, ['dualechoB0_ppm_zubal' '.nii']);

nii_vol = make_nii(multi_echo_b0_ppm);
save_nii(nii_vol, ['multiechoB0_ppm_zubal' '.nii']);


%% calculate the relative error

[err_dual] = zubal_err_fct('zubal_mask.nii.gz', dual_echo_b0_ppm, zubal_dBz.volume, 'sagital', 128);
mean_rel_error_dual = [mean_rel_error_dual, err_dual];
[err_multi] = zubal_err_fct('zubal_mask.nii.gz', multi_echo_b0_ppm, zubal_dBz.volume, 'sagital', 128);
mean_rel_error_multi = [mean_rel_error_multi, err_multi];

toc
end

%% Plot the error for different SNR

figure;
hold on
plot(list_SNR, mean_rel_error_dual, 'Color', 'b', 'Marker', 'o', 'LineWidth',1.5, 'LineStyle','-')
plot(list_SNR, mean_rel_error_multi, 'Color', 'r', 'Marker', 'o', 'LineWidth',1.5, 'LineStyle','-')
legend1 = legend('dual-echo', 'multi-echo');
set(legend1,'Location','best');
title({'SNR variation (New test2)'},{'Mean relative error from 0 to 300 with increment of 15'})
xlabel('SNR')
ylabel('error')
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


