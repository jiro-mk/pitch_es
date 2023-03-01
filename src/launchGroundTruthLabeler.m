% LAUNCHGROUNDTRUTHLABELER:
% Launch Ground Truth Labeler with ground truth data
% Please run tihs program after running testGtruthLabeler.m
%   Copyright 2019 The MathWorks, Inc.


tmp_des_gTruthPath = outputDirectoryPathInSlProj('gTruth');
tmpFiles = dir(fullfile(tmp_des_gTruthPath, '*.mat'));
tmpFileNames = {tmpFiles.name};

tmpDirNumCl= cell(numel(tmpFileNames), 1);
for iFile = 1:numel(tmpFileNames)
    tmpDirNum = extractBetween(tmpFileNames{iFile}, 'SMRC_', '_GroundTruth_DetectedObjectsRefined.mat');
    disp([num2str(iFile) ':' tmpDirNum{1}])
    tmpDirNumCl(iFile) = tmpDirNum;
end
tmpIdx = input('Choose Index Number:');

d = load(tmpFileNames{tmpIdx});
groundTruthLabeler(d.gTruth.DataSource)

clear tmp* gTruth* 
gTruth = d.gTruth;