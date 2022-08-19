
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
sectionMultiDual   = cell(1, length(list_SNR) * 2); % 
sectionDiff        = cell(1, length(list_SNR) * 2);

%% Generate phantom and measures
% generate a spherical susceptibility distribution 
spherical_sus_dist = Spherical(view_field , [res res res], radius, susceptibilities);
% save as nifti
spherical_sus_dist.save(sus_path);
% Plot
figure(1);
imagesc(spherical_sus_dist.volume(:,:,numCrossSection)); colorbar; title(sprintf('susceptibility distribution at z=%u', numCrossSection))


% compute the field shift for 1T for the susceptibility distribution
spherical_dBz = FBFest(spherical_sus_dist.volume, spherical_sus_dist.image_res, spherical_sus_dist.matrix);
% save as nifti
spherical_dBz.save(bdz_path);

figure(4);
imagesc(squeeze(1e6.*real(spherical_dBz.volume(:,:,numCrossSection)))); colorbar; title('true deltaB0 map at z=%u', numCrossSection))

for i = 1:length(list_SNR)
    fprintf('Calculate SNR %u...\n', list_SNR(i)); tic
    % simulate T2* decay for a cylinder of air surrounded by mineral oil with a
    % deltaB0 found in an external file
    spherical_vol = NumericalModel('Spherical3d', nb_voxels, res, radius, materialIn, materialOut);
    spherical_vol.generate_deltaB0('load_external', bdz_path);
    spherical_vol.simulate_measurement(FA, list_TE, list_SNR(i));


    % get magnitude and phase data
    magn = spherical_vol.getMagnitude;
    phase = spherical_vol.getPhase;
    compl_vol = magn.*exp(1i*phase);

    % calculate the deltaB0 map from the magnitude and phase data
    [dual_echo_delf] = +imutils.b0.dual_echo(compl_vol(:,:,:,1:2), list_TE(1:2));
    [multi_echo_delf] = +imutils.b0.multiecho_linfit(compl_vol, list_TE);

    % convert to ppm
    dual_echo_b0_ppm = 1e6*(dual_echo_delf/3)*(1/42.58e6);
    multi_echo_b0_ppm = 1e6*(multi_echo_delf/3)*(1/42.58e6);


    % save b0 maps
    nii_vol = make_nii(dual_echo_b0_ppm);
    save_nii(nii_vol, [dbz_ppm_dual_path sprintf('_SNR%u', list_SNR(i)) '.nii']);
    
    nii_vol = make_nii(multi_echo_b0_ppm);
    save_nii(nii_vol, [dbz_ppm_multi_path sprintf('_SNR%u', list_SNR(i)) '.nii']);
    
    %% store results

    sectionMultiDual{i} = squeeze(multi_echo_b0_ppm(:,:,numCrossSection));
    sectionMultiDual{i + length(list_SNR)} = squeeze(dual_echo_b0_ppm(:,:,numCrossSection));

    diff_multiecho = (multi_echo_b0_ppm-1e6.*real(spherical_dBz.volume));
    sectionDiff{i}  = squeeze(diff_multiecho(:,:,numCrossSection));
    diff_dualecho = (dual_echo_b0_ppm-1e6.*real(spherical_dBz.volume));
    sectionDiff{i + length(list_SNR)} = squeeze(diff_dualecho(:,:,numCrossSection));


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

