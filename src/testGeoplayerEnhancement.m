% TESTESTIMATEINITIALPITCH:
%   Copyright 2019 The MathWorks, Inc.

%% Define directory including sub directory of scene images
sampleDirPath = outputDirectoryPathInSlProj('Samples');
% folderNames = dir(sampleDirPath);
% folderNames = folderNames(3:end);
% folderNames = string({folderNames.name});

%% Define csv data directory
csvDataDirPath = outputDirectoryPathInSlProj('csv_Samples');

%% Extract sub directory names and scene IDs
csvDataFileNames =dir(csvDataDirPath);
csvDataFiles = string({csvDataFileNames.name});
csvDataFiles = csvDataFiles(3:end);
csvDataIds = regexprep(csvDataFiles,'ID|.csv','');

for iFile = 1:numel(csvDataIds)

    %% Get longitude and latitude data
    %Read CSV data
    warning off
    data = readtable(csvDataFiles(iFile));
    warning on
    
    % Time resolution of csv data
    numPoints = height(data);
    ts = 10/numPoints;
    tss = (0:ts:ts*(numPoints-1)).';
    
    %Extract longitude and latitude data and find unique data between them
    [lon, uniqueLongitudeIdx] = unique(data.Longitude);
    lat = data.Latitude(uniqueLongitudeIdx);
    
    if numel(lat) == 1
        disp(['GPS  not work with ' csvDataIds(iFile)])
        continue
    end
    
    % Initialize the player to view last 10 positions
    numPoints_h = ceil(numPoints/2);
    
    ts2 = tss(uniqueLongitudeIdx);
    
    % Calcualte arclen
    % arclen, of the great circle arcs connecting pairs of points on the 
    % surface of a sphere. In each case, the shorter (minor) arc is assumed. 
    % The function can also compute the azimuths, az, of the second point 
    % in each pair with respect to the first (that is, the angle at which 
    % the arc crosses the meridian containing the first point).
    [arclen,az] = distance(lat(1:end-1),lon(1:end-1),lat(2:end),lon(2:end));
    %deg2km(arclen)*1000
    
    xyCumsum = cumsum([deg2km(arclen)*1000 .* cosd(az) deg2km(arclen)*1000 .* sind(az)]);
    maxDistanceFromMedian = max(max(abs(xyCumsum - median(xyCumsum))));
    
    if maxDistanceFromMedian < 75
        zoomLevel = 18;
    elseif maxDistanceFromMedian < 125
        zoomLevel = 17;
    elseif maxDistanceFromMedian < 250
        zoomLevel = 16;
    elseif maxDistanceFromMedian < 500
        zoomLevel = 15;
    else
    end
    
    player = geoplayer(data.Latitude(numPoints_h), data.Longitude(numPoints_h), ...
        'ZoomLevel', zoomLevel, 'HistoryDepth', 10);
    
    %Note: 00105189 has ego-vehicle moving distance amounts to 
    %350m, cumsum(deg2km(arclen)*1000);
    
    %Generate actor distance since as of today there is not actor relative
    %positions (if we can obtain actor relative positions, then we can
    %calculate diff arclen and az)
    
    iFile
    median(diff(lat)<0)
    median(diff(lon)<0)
    sg = 2*(median(diff(lat)<0)) -1;
    arclen2 = -sg * km2deg(0.05) .* ones(size(lon));
    az(end+1) = az(end);
    [actLat, actLon] = reckon(lat, lon, arclen2, az);
    
    actLatq = interp1(ts2,actLat,tss);
    actLonq = interp1(ts2,actLon,tss);
    
    for i = numPoints
       if isnan(actLatq(i)) || isnan(actLatq(i))
           actLatq(i) = actLatq(i-1);
           actLonq(i) = actLonq(i-1);
       end
    end
    
    % Plot the positions
    for i = 1:numPoints
        if all(i ~= uniqueLongitudeIdx)
            continue
        end
        plotMultiRoute(player, [data.Latitude(i);actLatq(i)], [data.Longitude(i);actLonq(i) ]);
        pause(1)
    end

%     % Use imageDatastore to handle the scene images
%     sampleSubDirName = folderNames(iFile);
%     imds = imageDatastore(fullfile(sampleDirPath, sampleSubDirName));
%     numImFiles = length(imds.Files);
    
    
end