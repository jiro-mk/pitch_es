% TESTGTRUTHDIRECTORYCONVERTER: You need to locate mat
% files including gTruth data in source gTruth directory
% and save the data as mat file including lodable gTruth data in the 
% destination gTruth directory
%   Copyright 2018-2019 The MathWorks, Inc.

function testGtruthDirectoryConverter

% Define gTruth mat file directory
dataPath = outputDirectoryPathInSlProj('data');
source_gTruthDir = fullfile(dataPath, 'Original_gTruth');
gTruthMatFiles = dir(fullfile(source_gTruthDir, '*.mat'));
gTruthMatNames = string({gTruthMatFiles.name});
numGTruthFiles = length(gTruthMatNames);

des_gTruthPath = outputDirectoryPathInSlProj('gTruth');

% Check gTruth data directory exists
warning off
videDataFilePath = outputDirectoryPathInSlProj('videoData');
d = load(fullfile(source_gTruthDir, gTruthMatNames(1)));
switch class(d.gTruth)
    case 'groundTruth'
        isVideoDataDirCorrect = true;
    otherwise
        isVideoDataDirCorrect = contains(d.gTruth.DataSource.Source{1}, videDataFilePath);
end

sceneIds = extractSceneIds;

% if they does not exist, 
switch class(d.gTruth)
    case 'groundTruth'
        for iFile = 1:numGTruthFiles
            % Load gTruth
            d = load(fullfile(source_gTruthDir, gTruthMatNames(iFile)));
            gTruth = d.gTruth;

            % Replace target directories
            ds = gTruth.DataSource{1};
            targetDir = fileparts(fileparts(ds));
            sceneIdDir = fileparts(extractAfter(ds, targetDir));
            % DataSource = strrep(gTruth.DataSource, targetDir, videDataFilePath);
            numImageFiles = length(gTruth.DataSource);

            % Set sample frequency and time Stamp
            tr = 1/(numImageFiles/10);
            timeStamps = duration + (0:tr:tr * (numImageFiles-1))/(24 * 3600);

            gtlDataSource = groundTruthDataSource([videDataFilePath sceneIdDir], timeStamps.');

            %% Add Ground Truth label's attributes
            ldc = labelDefinitionCreator(gTruth.LabelDefinitions);

            for i = 1:height(gTruth.LabelDefinitions)
                addAttribute(ldc, gTruth.LabelDefinitions.Name{i}, 'X', 'Numeric', 0)
                addAttribute(ldc, gTruth.LabelDefinitions.Name{i}, 'Y', 'Numeric', 0)
                addAttribute(ldc, gTruth.LabelDefinitions.Name{i}, 'Yaw', 'Numeric', 0)
            end

            %% Attribute To be added to grund truth label data as struct class
            
            %% Form Ground Truth data gTruth
            gTruth = groundTruth(gtlDataSource, ldc.create, gTruth.LabelData);
            save(fullfile(des_gTruthPath, gTruthMatNames(iFile)), 'gTruth');

        end
    otherwise
end

warning on
end

function attribute = iGetAttribute
attribute = struct;
attribute.X = struct;
attribute.X.DefaultValue = [];
attribute.X.Description = '';
attribute.Y = struct;
attribute.Y.DefaultValue = [];
attribute.Y.Description = '';
attribute.Yaw = struct;
attribute.Yaw.DefaultValue = [];
attribute.Yaw.Description = '';
attribute.Type = labelType.Rectangle;
attribute.Description = '';

end