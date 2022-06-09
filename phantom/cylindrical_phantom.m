%% Cylindrical phantom

% Initialisation of the variables
dim = 128; % number of voxels ex:(128x128x128) 
res = 1; % image resolution in [mm]
R = 5; % radius of the cylinder in [mm]
angle = pi/2; % rotate the susceptibility distribution in the grid in [radian] (angle between principal axis of cylinder and B0)
susc = [0.36e-6 -8.842e-6]; % susceptibility of the phantom ex:[inside outside]
susc_in = 'air'; % material inside the cylinder ('silicone_oil', 'pure_mineral_oil', 'air')
susc_out = 'pure_mineral_oil'; % material outside the cylinder ('silicone_oil', 'pure_mineral_oil', 'air')
multi_TE = [0.001 0.002 0.003 0.004 0.005 0.006]; % echo time for the multi echo method in [sec]
dual_TE = multi_TE(1:2); % echo time for the dual echo method in [sec]
FA = 15; % flip angle for both methods in [degrees]
SNR = 50; % signal-to-noise ratio
dual_img = [];
multi_img = [];
z = zeros(128,5)+3;


% generate a cylindrical susceptibility distribution at 90 degrees 
cylindrical_sus_dist = Cylindrical( [dim dim dim], [res res res], R, angle, susc);
% save as nifti
cylindrical_sus_dist.save('cylindrical90_R5mm_airMineralOil_ChiDist.nii');
% save as nifti for different angle between main axis of cylinder and z-axis (in radians)
% cylindrical_sus_dist.save('pi_2_cylindrical_ChiDist.nii');
% cylindrical_sus_dist.save('pi_4_cylindrical_ChiDist.nii');


% compute deltaB0 for the simulated cylindrical susceptibility distribution
cylindrical_dBz = FBFest(cylindrical_sus_dist.volume, cylindrical_sus_dist.image_res, cylindrical_sus_dist.matrix);
% save as nifti
cylindrical_dBz.save('Bdz_cylindrical90_R5mm_airMineralOil_ChiDist');

% simulate T2* decay for a cylinder of air surrounded by mineral oil with a
% deltaB0 found in an external file
cylindrical_vol = NumericalModel('Cylindrical3d',dim,res,R,angle*(180/pi),susc_in, susc_out);
cylindrical_vol.generate_deltaB0('load_external', 'Bdz_cylindrical90_R5mm_airMineralOil_ChiDist.nii');
cylindrical_vol.simulate_measurement(FA, multi_TE, SNR);


% get magnitude and phase data
magn = cylindrical_vol.getMagnitude;
phase = cylindrical_vol.getPhase;
compl_vol = magn.*exp(1i*phase);


% calculate the deltaB0 map from the magnitude and phase data
[dual_echo_delf] = +imutils.b0.dual_echo(compl_vol(:,:,:,1:2), dual_TE);
[multi_echo_delf] = +imutils.b0.multiecho_linfit(compl_vol, multi_TE); 

dual_echo_b0_ppm = 1e6*(dual_echo_delf/3)*(1/42.58e6);
multi_echo_b0_ppm = 1e6*(multi_echo_delf/3)*(1/42.58e6);

% % save b0 maps
% nii_vol = make_nii(dual_echo_b0_ppm);
% save_nii(nii_vol, ['dualechoB0_ppm_cylindrical' '.nii']);
% 
% nii_vol = make_nii(multi_echo_b0_ppm);
% save_nii(nii_vol, ['multiechoB0_ppm_cylindrical' '.nii']);

% plot results

% % figure
% imagesc(squeeze(multi_echo_b0_ppm(:,:,64))); colorbar; title('multi-echo fit: b0 (ppm)')
% 
% figure
% imagesc(squeeze(dual_echo_b0_ppm(:,:,64))); colorbar; title('dual-echo fit: b0 (ppm)')
% 
% figure
% imagesc(squeeze(1e6.*real(cylindrical_dBz.volume(:,:,64))))
% colorbar
% title('Fourier-based field estimation for the cylinder: b0 (ppm)')
% 
% % calc diff between dual-echo and multi-echo
% diff_dualecho = (dual_echo_b0_ppm-1e6.*real(cylindrical_dBz.volume));
% figure; imagesc(squeeze(diff_dualecho(:,:,64))); colorbar; title('dual echo - true dBz');
% 
% diff_multiecho = (multi_echo_b0_ppm-1e6.*real(cylindrical_dBz.volume));
% figure; imagesc(squeeze(diff_multiecho(:,:,64))); colorbar; title('multi echo - true dBz');


% dual_img = [dual_img dual_echo_b0_ppm(:,:,64) ];
% multi_img = [multi_img multi_echo_b0_ppm(:,:,64)];
% 
% end 
%
% figure;
% imagesc(dual_img); colorbar; title('okok')
% figure;
% imagesc(multi_img); colorbar; title('asdf')
% 

