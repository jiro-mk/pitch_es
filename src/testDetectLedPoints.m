% TESTDETECTLEDPOINTS:
%   Copyright 2019 The MathWorks, Inc.

close all;
clear;

%% Define Directories
dataDir = outputDirectoryPathInSlProj('data');
ledImageDir = imageDatastore(fullfile(dataDir, 'CheckLed'));

%% Setup parameters
% Note:L84のmontage(regionGrayImages)を目視し、設置したLEDがregionInclLedsの中に入っているか確認
% 余計な部分を含めると後段のパラメータ設定が難しくなるため、ギリギリに設定する
ledRegion = [248 516 520 801];   % ledRegion including Leds [xMim xMax yMin yMax];

binaryTh = 190;                  % Treshold to binarize an gray-scaled image
minimumBlobArea = 4;             % Minimum object size
maximumBlobArea = 30;            % Maximum object size
numLeds = 6;                     % Number of located LEDs

% Define blob analyzer object
detectorObjects.blobAnalyzer = vision.BlobAnalysis(...
    'AreaOutputPort', false, ...
    'BoundingBoxOutputPort', true, ...
    'CentroidOutputPort', true, ...
    'ExcludeBorderBlobs',true, ...
    'MinimumBlobArea', minimumBlobArea, ...
    'MaximumBlobArea', maximumBlobArea);

%% Start simulation
numledImages = length(ledImageDir.Files);
regionInclLeds = cell(1, numledImages);
regionGrayRoiImages = regionInclLeds;
regionBinarizedRoiImages = regionInclLeds;

for iImage = 1:numledImages
    % Read image
    I = imread(ledImageDir.Files{iImage});

    % Apply RGB2Gray function to convert grayscale image
    gI = rgb2gray(I);

    % Binarize the grayscale image in ledRegion-of-interest
    idsX = ledRegion(1):ledRegion(2);
    idsY = ledRegion(3):ledRegion(4);
    bI = false(size(gI));
    bI(idsX, idsY) = gI(idsX, idsY) > binaryTh;

    % Store the intermediate data to check if parameters work correctly
    regionGrayRoiImages(iImage) = {gI(idsX, idsY)};
    regionBinarizedRoiImages(iImage) = {bI(idsX, idsY)};

    % Apply blob analysis for the binarized image
    [centroids, bboxes] = step(detectorObjects.blobAnalyzer, bI);

    % Choose target LED points
    % Note:LEDが対で水平に見えることを利用して、LED以外を削除する
    % [~, idx] = sort(centroids(:, 2));
    % centroids = centroids(idx, :);

    heightDiffPix = 0;
    finIdx = 0;
    while 1
        % 1ピクセルずつ範囲対象を大きくする
        heightDiffPix = heightDiffPix + 1;

        % LEDが個数分見つかった場合、もしくは高さ5ピクセル内に見つからなかった場合(fail)終了
        if nnz(finIdx) == numLeds  ||  heightDiffPix >= 5
            break
        end

        widthDiffPix = 5;
        doneIndxs = [];
        selCentroidsAndMean = [];
        while 1
            widthDiffPix = widthDiffPix + 1;

            % LEDが個数分見つかった場合、もしくは水平で中心から30ピクセル内に見つからなかった場合(fail)終了
            if nnz(finIdx) == numLeds  ||  widthDiffPix >= 30
                break
            end

            for i = 1:size(centroids, 1)
                if any(doneIndxs == i)
                    continue
                end

                indexes = abs(centroids(:, 2) - centroids(i, 2)) < heightDiffPix;
                idx = find(indexes);

                % Note:検索にひっかかったものは、次回から検索対象に入れない
                doneIndxs = [doneIndxs; idx];

                numCandidates = numel(idx);
                % Note:対であるという前提では、numCandidatesが2個以上必要
                if numCandidates < 2
                    continue
                end

                % Note:3つ以上見つかった場合には組み合わせを一つずつ調べる
                cidxes = nchoosek(1:numCandidates, 2);
                for j = size(cidxes, 1)
                    c = mean(centroids(idx(cidxes(j, :)), 1));
                    tmp = [centroids(idx(cidxes(j, :)), :) c * ones(2, 1)];
                    selCentroidsAndMean = [selCentroidsAndMean; tmp];
                end
            end
            finIdx = abs(selCentroidsAndMean(:, 3) - median(selCentroidsAndMean(:, 3))) < widthDiffPix;
        end
    end

    ledPoints = selCentroidsAndMean(finIdx, 1:2);

    addedI = (insertShape(I,'circle', [ledPoints 10*ones(size(ledPoints(:,1)))]));
    regionInclLeds(iImage) = {addedI};
end

% Show resulting data
figure;montage(regionGrayRoiImages)
figure;montage(regionInclLeds)
figure;montage(regionBinarizedRoiImages)