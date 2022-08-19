% Zubal phantom
 
% generate susceptibility distribution for my modified Zubal phantom
zubal_sus_dist = Zubal('/Users/mac/Documents/MATLAB/B0_sim-mapping/zubal_EAO.nii');
% save as nifti
zubal_sus_dist.save('zubal_EAO_sus.nii');
 
% compute deltaB0 for the simulated Zubal susceptibility distribution 
zubal_dBz = FBFest( zubal_sus_dist.volume, zubal_sus_dist.image_res, zubal_sus_dist.matrix, 'Zubal' ); % zubal_dBz units are in Tesla
% save as nifti
zubal_dBz.save('zubal_EAO_dBz.nii'); % zubal_dBz units are in ppm

% ppm to Hz
db0_zubal_Hz = ((267.52218744 * 10^6) / (2*pi)) * 3 * 1e-6 .* niftiread('zubal_EAO_dBz.nii'); % [rad*Hz/T][rad-1][T]

%% for loop initialisation
list_SNR = [5 10 15 20 30 50 75 100 150 200]; %  get different SNR
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
m_zubal_vol = NumericalModel('Zubal','/Users/mac/Documents/MATLAB/B0_sim-mapping/zubal_EAO.nii');
m_zubal_vol.generate_deltaB0('load_external', 'zubal_EAO_dBz.nii');
m_zubal_vol.simulate_measurement(24, [0.008 0.0095 0.011 0.0125 0.014 0.0155], list_SNR(k));
% dual-echo
d_zubal_vol = NumericalModel('Zubal','/Users/mac/Documents/MATLAB/B0_sim-mapping/zubal_EAO.nii');
d_zubal_vol.generate_deltaB0('load_external', 'zubal_EAO_dBz.nii');
d_zubal_vol.simulate_measurement(24, [0.00238 0.00476], list_SNR(k));


% get magnitude and phase data [Hz]
% multi-echo
m_magn = m_zubal_vol.getMagnitude;
m_phase = m_zubal_vol.getPhase;
m_compl_vol = m_magn.*exp(1i*m_phase);
% dual-echo
d_magn = d_zubal_vol.getMagnitude;
d_phase = d_zubal_vol.getPhase;
d_compl_vol = d_magn.*exp(1i*d_phase);
 
% calculate the deltaB0 map from the magnitude and phase data
[multi_echo_delf] = +imutils.b0.multiecho_linfit(m_compl_vol, [0.008 0.0095 0.011 0.0125 0.014 0.0155]); 
[dual_echo_delf] = +imutils.b0.dual_echo(d_compl_vol, [0.00238 0.00476]);

% % conversion to ppm
% dual_echo_b0_ppm = 1e6*(dual_echo_delf/3)*(1/42.58e6); % 3 for 3T, 42.58e6 Hz/T nucleus frequency, 1e6 for ppm
% multi_echo_b0_ppm = 1e6*(multi_echo_delf/3)*(1/42.58e6);

% % save b0 maps
% nii_vol = make_nii(dual_echo_b0_ppm);
% save_nii(nii_vol, ['dualechoB0_ppm_zubal' '.nii']);
%  
% nii_vol = make_nii(multi_echo_b0_ppm);
% save_nii(nii_vol, ['multiechoB0_ppm_zubal' '.nii']);
 
 
%% calculate the error
% 'meanvalue_and_niftifile' or 'meanvalue' or 'niftifile' for
% percent_err_fct and abs_err_fct

% conversion of the simulated volume to ppm 
% ppm_zubal_volume = real(zubal_dBz.volume) .* 1e6;

% mean relative error
[percent_diff_dual] = +imutils.error.percent_err_fct('PFC_mask.nii', dual_echo_delf, dB0_zubal_Hz, 'meanvalue', 'percent_dual_diff');
mean_rel_error_dual = [mean_rel_error_dual, percent_diff_dual];
 
[percent_diff_multi] = percent_err_fct('PFC_mask.nii', multi_echo_delf, dB0_zubal_Hz, 'meanvalue', 'percent_multi_diff');
mean_rel_error_multi = [mean_rel_error_multi, percent_diff_multi];

% mean absolute error
[abs_diff_dual] = abs_err_fct('PFC_mask.nii', dual_echo_delf, dB0_zubal_Hz, 'meanvalue', 'abs_dual_diff');
mean_abs_error_dual = [mean_abs_error_dual, abs_diff_dual];
 
[abs_diff_multi] = abs_err_fct('PFC_mask.nii', multi_echo_delf, dB0_zubal_Hz, 'meanvalue', 'abs_multi_diff');
mean_abs_error_multi = [mean_abs_error_multi, abs_diff_multi];

toc
end

%% Plot the error for different SNR
 
figure;
hold on
plot(list_SNR, mean_rel_error_dual, 'Color', 'b', 'Marker', 'o', 'LineWidth', 1.5, 'LineStyle','-')
plot(list_SNR, mean_rel_error_multi, 'Color', 'r', 'Marker', 'o', 'LineWidth', 1.5, 'LineStyle','-')
legend1 = legend('dual-echo', 'multi-echo');
set(legend1,'Location','best');
title({'SNR variation'},{'Mean relative error from 5 to 200'})
xlabel('SNR')
ylabel('relative error [%]')
grid on
hold off 

figure;
hold on
plot(list_SNR, mean_abs_error_dual, 'Color', 'b', 'Marker', 'o', 'LineWidth', 1.5, 'LineStyle','-')
plot(list_SNR, mean_abs_error_multi, 'Color', 'r', 'Marker', 'o', 'LineWidth', 1.5, 'LineStyle','-')
legend2 = legend('dual-echo', 'multi-echo');
set(legend2,'Location','best');
title({'SNR variation'},{'Mean absolute error from 5 to 200'})
xlabel('SNR')
ylabel('absolute error [Hz]')
grid on
hold off
