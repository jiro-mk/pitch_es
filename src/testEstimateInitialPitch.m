% TESTESTIMATEINITIALPITCH:
%   Copyright 2019 The MathWorks, Inc.

%% Define csv data directory
csvDataDirPath = outputDirectoryPathInSlProj('csv_Samples');

%% Extract sub directory names and scene IDs
csvDataFileNames =dir(csvDataDirPath);
csvDataFiles = string({csvDataFileNames.name});
csvDataFiles = csvDataFiles(3:end);
csvDataIds = regexprep(csvDataFiles,'ID|.csv','');

%% Start simulation
for iFile = 1:numel(csvDataIds)
    
    %Read CSV data
    warning off
    data = readtable(csvDataFiles(iFile));
    warning on
    
    %Extract longitude and latitude data and find unique data between them
    [lon, uniqueLongitudeIdx] = unique(data.Longitude);
    lat = data.Latitude(uniqueLongitudeIdx);

    h = zeros(size(uniqueLongitudeIdx));

    %Apply elevation extraction from GSI with their API
    baseUrl = 'http://cyberjapandata2.gsi.go.jp/general/dem/scripts/getelevation.php?';
    lonChr = ['lon=' num2str(lon(1))];
    latChr = ['lat=' num2str(lat(1))];
    gsiUrl = [baseUrl lonChr '&' latChr];
    urlData = webread(gsiUrl);
    h(1) = urlData.elevation;
   
    %Calculate relative distance from the start point
    d = distance(lat(1),lon(1), lat, lon,  referenceEllipsoid('GRS80','m'));
    %az0 = azimuth(lat(1),lon(1), lat, lon, 'radian');
    %recoveredPos = reckon(lat(1), lon(1), km2rad(d), az0);

    % Extract elevation from GSI website
    for j = 1:numel(uniqueLongitudeIdx)
        % Extract elevation of ego vehicle
        lonChr = ['lon=' num2str(lon(j))];
        latChr = ['lat=' num2str(lat(j))];
        gsiUrl = [baseUrl lonChr '&' latChr];
        urlData = webread(gsiUrl);
        h(j) = urlData.elevation;
    end

    if length(d) > 1
        pitch = rad2deg(atan2(h(2)-h(1), d(2)));
    else
        pitch = 0;
    end

    h2(iFile) = {h};
    d2(iFile) = {d};
    pitch2(iFile) = pitch;
    % az2(i) = {az};
end

close all
figure;for p=1:10, plot(d2{p}, h2{p}-h2{p}(1),'x-');hold on,;end;grid on;legend(csvDataIds);
xlabel('Distance [m]');
ylabel('Relative elevation [m]')

% figure;for p = 1:10, plot(d2{p}(2:end), az2{p}(2:end), 'x-');hold on, ;end;grid on;legend(csvDataIds);

% plot((cumsum(data.Speed_km_h_(1)/3.6 * ones(1, 449) + cumsum(data.Acceleration_z_g_) * ts) * ts))

% csvFileName = sprintf('ID% 08d.csv', eval(sampleSubDirName));
% metaData = readtable(fullfile(csvDataDirPath, csvFileName), opts);
    % Note:Time resolution (ts) depends on equipped sensor
        lon1 = lon(1);
    lat1 = lat(1);

    ts = 10/height(data);


   zz = cumsum(data.Acceleration_z_g_ * ts^2/2);
    yy = cumsum(data.Acceleration_y_g_ * ts^2/2);
        figure;plot(sqrt(sum(yy.^2+zz.^2,2)),'rx')

 