%% Cylindrical phantom
clearvars;
% Create a phantom for the cylindrical model

%% Parameters
% Phantom parameters
view_field = [128 128 128];
susceptibilities = [-8.842e-6 0.36e-6]; % [in, out]
res = 1; % [mm]
nb_voxels = 128;
radius = 5; % [mm]
theta = 0; % [radians]
materialIn = 'silicone_oil'; % ('air', 'silicone_oil' or 'pure_mineral_oil')
materialOut = 'pure_mineral_oil'; % ('air, 'silicone_oil, or 'pure_mineral_oil')

% Measure parameters 
% NB : These measure parameters have been optimized for the Zubal phantom
% and are not tested
dual_TE = [0.00238 0.00476]; % echo time in seconds for dual echo method
multi_TE = [0.008 0.0095 0.011 0.0125 0.014 0.0155]; % echo time in seconds for multi echo method
FA = 24; % flip angle in degrees
list_SNR = [25, 50];

% NIFTI parameters
sus_path = 'cylindrical_R5mm_airMineralOil_ChiDist_test.nii';
bdz_path = ['Bdz_' sus_path];
dbz_ppm_dual_path = 'dualechoB0_ppm_cylindrical';   % without extension
dbz_ppm_multi_path = 'multiechoB0_ppm_cylindrical'; % without extension
mask_cylindrical_path = 'mask_cylindrical';

% Display parameters
numCrossSection = view_field(1)/2 + 1;

%% Initialisation
% initialisation of the error vectors
mean_rel_error_dual = zeros(1, length(list_SNR));
mean_rel_error_multi = zeros(1, length(list_SNR));
mean_abs_error_dual = zeros(1, length(list_SNR));
mean_abs_error_multi = zeros(1, length(list_SNR));

%% Generate phantom and mask
% generate a cylindrical susceptibility distribution at 90 degrees 
cylindrical_sus_dist = Cylindrical(view_field, [res res res], radius, theta, susceptibilities);
% save as nifti
cylindrical_sus_dist.save(sus_path);
% Plot susceptibility map
figure(1); colormap gray
imagesc(cylindrical_sus_dist.volume(:,:,numCrossSection)); colorbar; title('susceptibility distribution')

% Generate a cylindrical mask
mask = cylindrical_mask(radius, theta, view_field, [res, res, res]);
mask_nii = make_nii(mask);
save_nii(mask_nii, [mask_cylindrical_path '.nii']);

%% Estimate field variation
% compute the field shift for 1T for the simulated cylindrical susceptibility distribution
% A buffer can be applied (see FBFest.m) here the default one is used
cylindrical_dBz = FBFest('cylindrical', cylindrical_sus_dist.volume, cylindrical_sus_dist.image_res, cylindrical_sus_dist.matrix, cylindrical_sus_dist.sus(2));
% save as nifti
cylindrical_dBz.save(bdz_path);
% Plot delta B0 map
figure(2); colormap gray
imagesc(squeeze(1e6.*real(cylindrical_dBz.volume(:,:,numCrossSection)))); colorbar; title('true deltaB0 map')

% ppm to Hz
dB0_Hz = ((267.52218744 * 10^6) / (2*pi)) * 3 * 1e-6 .* niftiread(bdz_path); % [rad*Hz/T][rad-1][T]

for i = 1:length(list_SNR)
    fprintf('Calculate SNR %u...\n', list_SNR(i)); tic
    % simulate T2* decay for a cylinder of material in surrounded by material out with a
    % deltaB0 found in an external file
    % multi echo
    m_cylindrical_vol = NumericalModel('Cylindrical3d', nb_voxels, res, radius, theta, materialIn, materialOut);
    m_cylindrical_vol.generate_deltaB0('load_external', bdz_path);
    m_cylindrical_vol.simulate_measurement(FA, multi_TE, list_SNR(i));
    % dual echo
    d_cylindrical_vol = NumericalModel('Cylindrical3d', nb_voxels, res, radius, theta, materialIn, materialOut);
    d_cylindrical_vol.generate_deltaB0('load_external', bdz_path);
    d_cylindrical_vol.simulate_measurement(FA, dual_TE, list_SNR(i));


    % get magnitude and phase data
    % multi echo
    m_magn = m_cylindrical_vol.getMagnitude;
    m_phase = m_cylindrical_vol.getPhase;
    m_compl_vol = m_magn.*exp(1i*m_phase);
    % dual echo
    d_magn = d_cylindrical_vol.getMagnitude;
    d_phase = d_cylindrical_vol.getPhase;
    d_compl_vol = d_magn.*exp(1i*d_phase);

    % calculate the deltaB0 map from the magnitude and phase data
    [dual_echo_delf] = +imutils.b0.dual_echo(m_compl_vol, multi_TE);
    [multi_echo_delf] = +imutils.b0.multiecho_linfit(d_compl_vol, dual_TE);

    % % conversion to ppm
    % dual_echo_b0_ppm = 1e6*(dual_echo_delf/3)*(1/42.58e6); % 3 for 3T, 42.58e6 Hz/T nucleus frequency, 1e6 for ppm
    % multi_echo_b0_ppm = 1e6*(multi_echo_delf/3)*(1/42.58e6);

    % % save b0 maps
    % nii_vol = make_nii(dual_echo_b0_ppm);
    % save_nii(nii_vol, [dbz_ppm_dual_path sprintf('_SNR%u', list_SNR(i)) '.nii']);
    
    % nii_vol = make_nii(multi_echo_b0_ppm);
    % save_nii(nii_vol, [dbz_ppm_multi_path sprintf('_SNR%u', list_SNR(i)) '.nii']);
    
     %% calculate the error
    % 'meanvalue_and_niftifile' or 'meanvalue' or 'niftifile' for
    % percent_err_fct and abs_err_fct

    % conversion of the simulated volume to ppm 
    % ppm_zubal_volume = real(zubal_dBz.volume) .* 1e6; % only if you're using ppm
    
    % mean relative error
    [percent_diff_dual] = +imutils.error.percent_err_fct([mask_cylindrical_path '.nii'], dual_echo_delf, dB0_Hz, 'meanvalue', 'percent_dual_diff');
    mean_rel_error_dual(i) = percent_diff_dual;

    [percent_diff_multi] = +imutils.error.percent_err_fct([mask_cylindrical_path '.nii'], multi_echo_delf, dB0_Hz, 'meanvalue', 'percent_multi_diff');
    mean_rel_error_multi(i) = percent_diff_multi;

    % mean absolute error
    [abs_diff_dual] = +imutils.error.abs_err_fct([mask_cylindrical_path '.nii'], dual_echo_delf, dB0_Hz, 'meanvalue', 'abs_dual_diff');
    mean_abs_error_dual(i) = abs_diff_dual;

    [abs_diff_multi] = +imutils.error.abs_err_fct([mask_cylindrical_path '.nii'], multi_echo_delf, dB0_Hz, 'meanvalue', 'abs_multi_diff');
    mean_abs_error_multi(i) = abs_diff_multi;
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
