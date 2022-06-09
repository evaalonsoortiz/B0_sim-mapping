% A = rand(128);
% B = 10*rand(128);
% C = 100*rand(128);
% d = 10000*rand(128);
% D = {A B
%      C d};
% 
% minColorLimit = min([min(min(D{1})) min(min(D{2})) min(min(D{3})) min(min(D{4}))]);
% maxColorLimit = max([max(max(D{1})) max(max(D{2})) max(max(D{3})) max(max(D{4}))]);
% 
% fig=figure(1);
% for i = 1 : length(D) 
%     sph{i} = subplot( 1, length(D), i, 'Parent',fig);
%     imagesc(sph{i}, D{i});
%     caxis(sph{i},[minColorLimit,maxColorLimit]);
% end
% 
% h = axes(fig,'visible','off'); 
% h.Title.Visible = 'on';
% h.XLabel.Visible = 'on';
% h.YLabel.Visible = 'on';
% ylabel(h,'y axis','FontWeight','bold');
% xlabel(h,'x axis','FontWeight','bold');
% title(h,'title');
% c = colorbar(h,'Position',[0.93 0.168 0.022 0.7]);  % attach colorbar to h
% colormap(c,'jet')
% caxis(h,[minColorLimit,maxColorLimit]);             % set colorbar limits


A = [1 2 3 ; 4 5 6; 7 8 9];    % Dual
AA = [1 2 3 ; 4 5 6; 7 8 9];   % Dual
AAA = [1 2 3 ; 4 5 6; 7 8 9];  % Dual
B = [10 2 3 ; 0 5 6; 7 8 9];   % Multi
BB = [10 2 3 ; 0 5 6; 7 8 9];  % Multi
BBB = [10 2 3 ; 0 5 6; 7 8 9]; % Multi

% on met tout dans un vecteur (concaténation)
D = {A AA AAA B BB BBB};

minColorLimit = min(min(cell2mat(D)));
maxColorLimit = max(max(cell2mat(D)));


fig1 = figure(1);
fig = figure(2);

for i = 1 : length(D)/2 
    sph{i} = subplot( 1, length(D)/2, i, 'Parent',fig1);
    imagesc(sph{i}, D{i}); title(sprintf('%u',i))
    caxis(sph{i},[minColorLimit,maxColorLimit]);
    
    sph{i + length(D)/2} = subplot( 1, length(D)/2, i, 'Parent',fig1);
    imagesc(sph{i}, D{i}); title(sprintf('%u',i))
    caxis(sph{i},[minColorLimit,maxColorLimit]);
end

h = axes(fig1,'visible','off'); 
h.Title.Visible = 'on';
h.XLabel.Visible = 'on';
h.YLabel.Visible = 'on';
ylabel(h,'y axis','FontWeight','bold');
xlabel(h,'x axis','FontWeight','bold');
sgtitle('Subplot Grid Title')
c = colorbar(h,'Position',[0.93 0.168 0.022 0.7]);  % attach colorbar to h
colormap
caxis(h,[minColorLimit,maxColorLimit]);             % set colorbar limits
