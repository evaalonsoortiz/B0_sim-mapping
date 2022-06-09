function displayExperiment(nlines, dataCells, listVar, listTitles, nameVar, globalTitle)
% display experiment displays 2D matrixes in subplots in a window with the
% same colorbar.
%
% _SYNTAX_
% 
% displayExperiment()
%
% _DESCRIPTION_
% The display will be (ncolumns = length(listVar)  :
%  __________     __________         __________________
% | var1       |   | var2       |        | var ncolumns  |  
% | model1 |   | model1 |  .....   | model1           | 
% |__________|   |__________|        |_________________|
%                             ...
%                             ...
%                             ...
%  ________________     ________________              _________________
% | var1                |   | var2                |            | var ncolumns  |  
% | model nlines  |   | model nlines  |   .....     | model nlines  | 
% |________________|   |________________|            |________________|
% _INPUT ARGUMENTS_
%    nlines
%      number of lines to display on the window
%    dataCells
%      A cell array which contains the data that has to be displayed, on a single line. Therefore its
%      dimension has to be 1 x (nlines x ncolumns).
%    listVar
%      A list of the variable that was varying during the experiment.
%    listTitles
%      A list of the titles (class 'char') for each model. Its length has to be equal to
%      ncolumns.
%    nameVar
%      The name for the modified variable (class 'char').
%    nameVar
%      The  global title (class 'char').
% _OUTPUTS_
% 
% Code created for https://github.com/evaalonsoortiz/B0_sim-mapping/

ncolumns = length(listVar);
colorLim = [min(min(cell2mat(dataCells))) max(max(cell2mat(datacells)))];
fig = figure;

for i=1 : nlines * ncolumns
    texte = listTitles(ceil(i / ncolumns);
    sp{i} = subplot(nlines, ncolumns, i, 'Parent', fig);
    imagesc(sp{i}, dataCells{i});
    title(sprintf('%s %s %u', texte, nameVar, listVar(mod(i - 1, ncolumns) + 1)));
    caxis(sp{i}, colorLim);
end

h = axes(fig, 'visible', 'off');
h.Title.Visible = 'on';
h.XLabel.Visible = 'off';
h.YLabel.Visible = 'off';
sgtitle(h, globalTitle);
c = colorbar(h, 'Position', [0.93 0.168 0.022 0.7]);
caxis(h, colorLim);
end


