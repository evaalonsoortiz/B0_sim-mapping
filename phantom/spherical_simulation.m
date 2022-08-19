
%% Spherical phantom
% Simulate the field map and apply both dual echo and multi echo methods
% for different SNRs for a spherical phantom

%clearvars;

%% Parameters
% Phantom parameters
view_field = [128 128 128];
susceptibilities = [-8.842e-6 0.36e-6]; % [in, out]
res = 1; % [mm]
nb_voxels = 128;
radius = 5; % [mm]
materialIn = 'air'; % ('air', 'silicone_oil' or 'pure_mineral_oil')
materialOut = 'pure_mineral_oil'; % ('air, 'silicone_oil, or 'pure_mineral_oil')

% Measure parameters 
% NB : These measure parameters have been optimized for the Zubal phantom
% and are not tested
dual_TE = [0.00238 0.00476]; % echo time in seconds for dual echo method
multi_TE = [0.008 0.0095 0.011 0.0125 0.014 0.0155]; % echo time in seconds for multi echo method
FA = 24; % flip angle in degrees
list_SNR = [25, 50];

% NIFTI parameters
sus_path = 'spherical_R5mm_airMineralOil_ChiDist_test.nii';
bdz_path = ['Bdz_' sus_path];
dbz_ppm_dual_path = 'dualechoB0_ppm_spherical';   % without the extension
dbz_ppm_multi_path = 'multiechoB0_ppm_spherical'; % without the extension

% Display parameters
numCrossSection    = 64; % The section that will be displayed

%% Initialisation
% initialisation of the error vectors
mean_rel_error_dual = zeros(1, length(list_SNR));
mean_rel_error_multi = zeros(1, length(list_SNR));
mean_abs_error_dual = zeros(1, length(list_SNR));
mean_abs_error_multi = zeros(1, length(list_SNR));

%% Generate phantom
% generate a spherical susceptibility distribution 
spherical_sus_dist = Spherical(view_field , [res res res], radius, susceptibilities);
% save as nifti
spherical_sus_dist.save(sus_path);
% Plot
figure(1); colormap gray
imagesc(spherical_sus_dist.volume(:,:,numCrossSection)); colorbar; title(sprintf('susceptibility distribution at z=%u', numCrossSection))

%% Estimate field variation
% compute the field shift for 1T for the susceptibility distribution
spherical_dBz = FBFest(spherical_sus_dist.volume, spherical_sus_dist.image_res, spherical_sus_dist.matrix);
% save as nifti
spherical_dBz.save(bdz_path);

figure(4); colormap gray
imagesc(squeeze(1e6.*real(spherical_dBz.volume(:,:,numCrossSection)))); colorbar; title(sprintf('true deltaB0 map at z=%u', numCrossSection))

%% Generate measures
for i = 1:length(list_SNR)
    fprintf('Calculate SNR %u...\n', list_SNR(i)); tic
    % simulate T2* decay with a deltaB0 found in an external file
    % multi echo
    m_spherical_vol = NumericalModel('Spherical3d', nb_voxels, res, radius, materialIn, materialOut);
    m_spherical_vol.generate_deltaB0('load_external', bdz_path);
    m_spherical_vol.simulate_measurement(FA, multi_TE, list_SNR(i));
    % dual echo
    d_spherical_vol = NumericalModel('Spherical3d', nb_voxels, res, radius, materialIn, materialOut);
    d_spherical_vol.generate_deltaB0('load_external', bdz_path);
    d_spherical_vol.simulate_measurement(FA, dual_TE, list_SNR(i));

    % get magnitude and phase data [Hz]
    % multi echo
    m_magn = spherical_vol.getMagnitude;
    m_phase = spherical_vol.getPhase;
    m_compl_vol = magn.*exp(1i*phase);    
    % dual echo
    d_magn = spherical_vol.getMagnitude;
    d_phase = spherical_vol.getPhase;
    d_compl_vol = magn.*exp(1i*phase);

    % calculate the deltaB0 map from the magnitude and phase data
    [multi_echo_delf] = +imutils.b0.multiecho_linfit(m_compl_vol, multi_TE);
    [dual_echo_delf] = +imutils.b0.dual_echo(d_compl_vol, dual_TE);
    
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
    [percent_diff_dual] = +imutils.error.percent_err_fct('PFC_mask.nii', dual_echo_delf, dB0_zubal_Hz, 'meanvalue', 'percent_dual_diff');
    mean_rel_error_dual(k) = percent_diff_dual;

    [percent_diff_multi] = +imutils.error.percent_err_fct('PFC_mask.nii', multi_echo_delf, dB0_zubal_Hz, 'meanvalue', 'percent_multi_diff');
    mean_rel_error_multi(k) = percent_diff_multi;

    % mean absolute error
    [abs_diff_dual] = +imutils.error.abs_err_fct('PFC_mask.nii', dual_echo_delf, dB0_zubal_Hz, 'meanvalue', 'abs_dual_diff');
    mean_abs_error_dual(k) = abs_diff_dual;

    [abs_diff_multi] = +imutils.error.abs_err_fct('PFC_mask.nii', multi_echo_delf, dB0_zubal_Hz, 'meanvalue', 'abs_multi_diff');
    mean_abs_error_multi(k) = abs_diff_multi;
    toc
end



%% plot
% plot results

colorLim2 = [min(min(cell2mat(sectionMultiDual))) max(max(cell2mat(sectionMultiDual)))];
colorLim3 = [min(min(cell2mat(sectionDiff))) max(max(cell2mat(sectionDiff)))];

fig2 = figure(2);
fig3 = figure(3);

for i=1:2 * length(list_SNR)
    if (i > length(list_SNR)) 
        texte = 'dual'; 
    else
        texte = 'multi';
    end
    spMD{i} = subplot(2, length(list_SNR), i, 'Parent', fig2);
    imagesc(spMD{i}, sectionMultiDual{i}); title(sprintf('B0 maps %s SNR %u', texte, list_SNR(mod(i - 1, length(list_SNR)) + 1)));
    caxis(spMD{i}, colorLim);

    spDiff{i} = subplot(2, length(list_SNR), i, 'Parent', fig3);
    imagesc(spDiff{i}, sectionDiff{i}); title(sprintf('B0 difference %s SNR %u', texte, list_SNR(mod(i - 1, length(list_SNR)) + 1)));
    caxis(spDiff{i}, colorLim);
end

h2 = axes(fig2, 'visible', 'off');
h2.Title.Visible = 'on';
h2.XLabel.Visible = 'on';
h2.YLabel.Visible = 'on';
ylabel(h2, 'yaxis');
xlabel(h2, 'yaxis');
sgtitle(h2, sprintf('Spherical Phantom : B0 measured maps (numVox=%u, FA=%0.1f, SNR variable, deltaTE=%0.4f)', nb_voxels, FA, list_TE(2) - list_TE(1)));
c2 = colorbar(h2, 'Position', [0.93 0.168 0.022 0.7]);
caxis(h2, colorLim);

h3 = axes(fig3, 'visible', 'off');
h3.Title.Visible = 'on';
h3.XLabel.Visible = 'on';
h3.YLabel.Visible = 'on';
ylabel(h3, 'yaxis');
xlabel(h3, 'yaxis');
sgtitle(h3, sprintf('Spherical Phantom : difference between true dBz and measures maps (numVox=%u, FA=%0.1f, SNR variable, deltaTE=%0.4f)', nb_voxels, FA, list_TE(2) - list_TE(1)));
c3 = colorbar(h3, 'Position', [0.93 0.168 0.022 0.7]);
caxis(h3, colorLim);

