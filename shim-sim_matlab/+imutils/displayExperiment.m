function success = displayExperiment(nlines, dataCells, listVar, listTitles, nameVar, globalTitle)
% display experiment displays 2D matrixes in subplots in a window with the
% same colorbar.
%
% _SYNTAX_
% 
% displayExperiment(int, cell array, [int, int, ...], {'xxx', 'xxx', ...}, 'xxx', 'xxx xxx xxx')
% 
%
% _DESCRIPTION_
% The display will be (ncolumns = length(listVar)  :
% 
% var1         var2       ...      var ncolumns
% model1       model1      ...     model1 
%                          ...
%                         ...
% var1          var2        ...     var ncolumns 
% model nlines	model nlines ...	model nlines
%s
% _INPUT ARGUMENTS_
%    nlines
%      number of lines to display on the window
%    dataCells
%      A cell array which contains the data that has to be displayed, on a single line. Therefore its
%      dimension has to be 1 x (nlines x ncolumns).
%    listVar
%      A list of the variable that was varying during the experiment.
%    listTitles
%      A cell array of the titles (class 'char') for each model. Its length has to be equal to
%      ncolumns.
%    nameVar
%      The name for the modified variable (class 'char').
%    nameVar
%      The global title (class 'char').
%
% _OUTPUTS_
%    success
%      1 if the function has succefully succeed
%
%_EXAMPLE_
% s = +imutils.displayExperiment(2, sectionMultiDual, list_SNR, {'multi_echo', 'dual_echo'}, 'SNR', 'Comparing dual and multi echo methods for different SNR');
%
% Code created for https://github.com/evaalonsoortiz/B0_sim-mapping/

ncolumns = length(listVar);
colorLim = [min(min(cell2mat(dataCells))) max(max(cell2mat(dataCells)))];
fig = figure;

for i=1 : nlines * ncolumns
    texte = listTitles(ceil(i / ncolumns));
    sp{i} = subplot(nlines, ncolumns, i, 'Parent', fig);
    imagesc(sp{i}, dataCells{i});
    title(sprintf('%s %s %s', texte, nameVar, listVar(mod(i - 1, ncolumns) + 1)));
    caxis(sp{i}, colorLim);
    set(gca,'XTick',[],'YTick',[])
end

h = axes(fig, 'visible', 'off');
h.Title.Visible = 'on';
h.XLabel.Visible = 'off';
h.YLabel.Visible = 'off';

c = colorbar(h, 'Position', [0.93 0.168 0.022 0.7]);
colorTitleHandle = get(c,'Title');
titleString = 'rad';
set(colorTitleHandle ,'String',titleString);

caxis(h, colorLim);
sgtitle(globalTitle);
colormap gray


success = 1;
end
