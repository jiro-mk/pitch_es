classdef (Sealed) geoplayer < vision.internal.EnforceScalarHandle
    % GEOPLAYER Player for visualizing streaming geographic coordinates
    %   player = geoplayer(latCenter,lonCenter) returns a player for
    %   visualizing streaming geographic coordinates centered at latitude
    %   and longitude coordinates given by latCenter and lonCenter. Values
    %   for latitude and longitude must be in the range (-90,90) and
    %   [-180,180], respectively.
    %
    %   player = GEOPLAYER(latCenter,lonCenter,zoomLevel) additionally
    %   specifies a magnification level zoomLevel, as an integer between 0
    %   and 25. Zoom level is specified on a logarithmic scale with base 2.
    %   Increasing the zoomLevel value by 1 doubles the map scale. The
    %   default zoomLevel is 15.
    %
    %   player = GEOPLAYER(...,Name,Value) specifies additional name-value
    %   pair arguments described below:
    %
    %   'HistoryDepth'  Number of previous geographic coordinates to
    %                   display,specified as a scalar integer. A value of 0
    %                   displays only new geographic coordinates, with no
    %                   history. A value of Inf displays all geographic
    %                   coordinates previously plotted using plotPosition.
    %                   Increase this value if successive geographic
    %                   coordinates are very close to each other.
    %
    %                   Default: 0
    %
    %   'HistoryStyle'  Type of graphic display for the previous geographic
    %                   coordinates, specified as either 'point' or 'line'.
    %
    %                   ---------------------------------------------------
    %                   Track Style   | Description
    %                   --------------|------------------------------------
    %                   'point'       | The track is displayed as 
    %                                 | individual, unconnected points.
    %                   --------------|------------------------------------
    %                   'line'        | The track is displayed as a single
    %                                 | connected line.
    %                   ---------------------------------------------------
    %
    %                   If 'HistoryDepth' property is set to 0, this
    %                   property has no effect.
    %
    %                   Default: 'point'
    %
    %   'Parent'        Parent of the player, specified as a figure or
    %                   panel object. If you do not specify 'Parent',
    %                   geoplayer creates the player in a new figure.
    %
    %
    %   GEOPLAYER properties:
    %   HistoryDepth  - Number of previous positions to display. (read-only)
    %   HistoryStyle  - Display style for previous positions. (read-only)
    %   Parent        - Container of the player. (read-only)
    %
    %   GEOPLAYER methods:
    %   plotPosition  - Display the current position.
    %   plotRoute     - Display a series of points as a route.
    %   reset         - Remove all existing plots from player.
    %   show          - Make the player figure visible.
    %   hide          - Make the player figure invisible.
    %   isOpen        - Returns true if the player is visible, else false.
    %
    %   Notes
    %   -----
    %   - geoplayer displays geographic map tiles using World Street Map
    %     provided by Esri. This basemap requires access to an Internet
    %     connection in order to fetch map tiles. Information about the 
    %     Esri ArcGIS Online layers is available <a href="http://goto.arcgisonline.com/maps/World_Street_Map">here</a>.
    %
    %   - Geographic map tiles may not be available for all locations.
    %
    %
    %   Example 1 - View a latitude and longitude sequence
    %   --------------------------------------------------
    %
    %   % Load latitude and longitude coordinates
    %   data = load('geoSequence.mat');
    %
    %   % Create the player and configure it to display history
    %   player = geoplayer(data.latitude(1), data.longitude(1), 'HistoryDepth', Inf);
    %
    %   % Display the coordinates in a sequence
    %   for i = 1:length(data.latitude)
    %     plotPosition(player, data.latitude(i), data.longitude(i));
    %   end
    %
    %
    %   Example 2 - View a vehicle's position along a route
    %   ---------------------------------------------------
    %
    %   % Load the route and vehicle positions
    %   data = load('geoRoute.mat');
    %
    %   % Create the player starting with the first position
    %   player = geoplayer(data.latitude(1), data.longitude(1), 12);
    %
    %   % Display the full route
    %   plotRoute(player, data.latitude, data.longitude);
    %
    %   % Display positions of the vehicle
    %   for i = 1:length(data.latitude)
    %     plotPosition(player, data.latitude(i), data.longitude(i))
    %   end
    %
    %
    %   See also GEOBUBBLE
    
    %   Copyright 2017-2018 The MathWorks, Inc.
    
    properties(SetAccess = private)
        %HistoryDepth - Number of previous positions to display.
        %   A scalar integer between 0 and Inf, specifying the number of
        %   previous positions to display. When you set this value to 0, no
        %   previous values are displayed. When you set this value to Inf,
        %   all previous values are displayed. Increase this value if
        %   successive geographic coordinates are very close to each other.
        %
        %   Default: 0
        HistoryDepth
        
        %HistoryStyle - Display style for previous positions.
        %   Type of graphic display for the previous geographic coordinates
        %   of the track, specified as either 'point' or 'line'.
        %
        %   ---------------------------------------------------------------
        %   Path Style   | Description
        %   -------------|-------------------------------------------------
        %   'point'      | The track is displayed as individual,
        %                | unconnected points.
        %   -------------|-------------------------------------------------
        %   'line'       | The track is displayed as a single connected
        %                | line.
        %   ---------------------------------------------------------------
        %
        %   If HistoryDepth property is set to 0, this property has no
        %   effect.
        %
        %   Default: 'point'
        HistoryStyle
    end
    
    properties(Dependent, SetAccess = private)
        %Parent - Container of the player.
        %   Parent of the player, specified as a figure or panel object.
        %   If you do not specify 'Parent', geoplayer creates the player
        %   in a new figure.
        %
        %   See also FIGURE, UIPANEL
        Parent
    end
    
    properties(Hidden, Dependent, SetAccess = private)
        %MapCenter - Center point of the player in [latitude, longitude].
        MapCenter
        
        %ZoomLevel - Zoom level of the player.
        ZoomLevel
        
        %Basemap - Map on which to plot data.
        %   Map on which to plot data, specified as one of the string
        %   scalars or character vectors 'darkwater', 'grayland',
        %   'bluegreen', 'colorterrain', 'grayterrain', 'landcover'.
        %   Additionally, it can be specified as a scalar structure with
        %   fields Name, URL and Attribution. Name is a string scalar or
        %   character vector specifying the name of the basemap, URL is a
        %   scalar string or character vector specifying the URL of the
        %   basemap to be used to fetch tiles and ATTRIBUTION is a scalar
        %   string or character vector specifying the attribution for the
        %   basemap.
        %
        %   Example - Use HERE streets map tiles
        %   ------------------------------------
        %   name = 'here_streets';
        %
        %   % Create base URL
        %   hereBase ='https://2.base.maps.cit.api.here.com/maptile/2.1/maptile/'
        %   hereBasemap = 'newest/normal.day/${z}/${x}/${y}/256/png?app_id=%s&app_code=%s';
        %
        %   % Ask user for HERE tokens (app id and app code)
        %   hereTokens = inputdlg({'APP ID', 'APP Code'}, 'HERE Tokens');
        %
        %   % Construct url string
        %   url = [hereBase sprintf(hereBasemap, hereTokens{1}, hereTokens{2})];
        %
        %   attribution = 'Tiles Courtesy of HERE';
        %
        %   % Create struct with fields Name, URL and Attribution
        %   basemap.Name        = name;
        %   basemap.URL         = url;
        %   basemap.Attribution = attribution;
        %
        %   % Load latitude and longitude coordinates
        %   data = load('geoSequence.mat');
        %
        %   % Create geoplayer
        %   player = geoplayer(data.latitude(1), data.longitude(1), ...
        %       'Basemap', basemap, 'HistoryDepth', inf);
        %
        %   % Display the coordinates in a sequence
        %   for i = 1 : length(data.latitude)
        %       plotPosition(player, data.latitude(i), data.longitude(i));
        %   end
        Basemap
    end
    
    properties(Access = private)
        %ColorOrder - Predefined colors for multiline plots.
        ColorOrder double = get(0, 'FactoryAxesColorOrder')
        
        %IsEmbedded - Checks if player is in a user-defined figure.
        IsEmbedded logical = false
    end
    
    properties(Hidden, Access = ?GeoplayerTestHelper)
        %Routes - Handles to the static routes.
        Routes driving.internal.geo.PlayerRoute
        
        %Path - Handle to the updating path.
        Path driving.internal.geo.PlayerPath
    end
    
    properties(Transient, Access = private)
        %Chart - Geographic chart on which the data is plotted.
        Chart
    end
    
    properties (Access = protected)
        %Version - Toolbox version to be saved with geoplayer.
        Version = ver('driving');
    end
    
    % Get methods (Dependent)
    methods
        
        % Get the basemap of the player
        function basemap = get.Basemap(obj)
            basemap = obj.Chart.Basemap;
        end
        
        % Get the map center of the player
        function mapCenter = get.MapCenter(obj)
            mapCenter = obj.Chart.MapCenter;
        end
        
        % Set the map center of the player
        function set.MapCenter(obj, mapCenter)
            obj.Chart.MapCenter = mapCenter;
        end
        
        % Get the zoom level of the player
        function zoomLevel = get.ZoomLevel(obj)
            zoomLevel = obj.Chart.ZoomLevel;
        end
        
        % Get the parent of the player
        function parent = get.Parent(obj)
            parent = obj.Chart.Parent;
        end
        
    end
    
    methods
        
        % Constructor
        function obj = geoplayer(varargin)
            params = obj.parsePlayerParameters(varargin{:});
            obj.initializePlayer(params);
        end
        
        % Destructor
        function delete(obj)
            % If the player is embedded, delete the chart object. Else,
            % delete the parent figure.
            if ~isvalid(obj) && ~isempty(obj.Chart)
                if obj.IsEmbedded
                    delete(obj.Chart);
                elseif isvalid(obj.Chart)
                    delete(obj.Parent);
                end
            end
        end
        
        function plotPosition(obj, varargin)
            % plotPosition Display current geographic position an object.
            %
            %   plotPosition(player,latitude,longitude) plot position
            %   specified by latitude and longitude, which are scalars in
            %   the range [-90, 90] and [-180, 180], respectively.
            %
            %   plotPosition(...,Name,Value) specifies additional
            %   name-value pair arguments described below:
            %
            %   'Label'         Text description corresponding to the
            %                   current position, specified as a character
            %                   vector or string.
            %
            %                   Default: ''
            %
            %   'Color'         Marker face color, specified as an RGB
            %                   triplet, a character vector or a color
            %                   name. An RGB triplet is a three-element row
            %                   vector whose elements specify the
            %                   intensities of the red, green, and blue
            %                   components of the color. The intensities
            %                   must be in the range [0,1]. Color is only
            %                   used for filled marker symbols.
            %
            %                   Default: Color is selected automatically
            %
            %   'Marker'        Marker symbol for current position,
            %                   specified as one of the following values:
            %
            %                   .   point   x  x-mark     ^ triangle (up)
            %                   o   circle  d  diamond    v triangle (down)
            %                   +   plus    p  pentagram  < triangle (left)
            %                   *   star    h  hexagram   > triangle (right)
            %                   s   square
            %
            %                   Default: 'o' (circle)
            %
            %   'MarkerSize'    Approximate diameter of the position
            %                   marker, specified as a positive value in
            %                   points.
            %
            %                   Default: 6
            %
            %
            %   Notes
            %   -----
            %   - geoplayer automatically updates the map limits to display
            %     new positions added by plotPosition.
            %
            %
            %   Example - View vehicle's current position
            %   -------------------------------------------
            %
            %   % Load data for the route
            %   data = load('geoRoute.mat');
            %
            %   % Initialize the player to view last 10 positions
            %   player = geoplayer(data.latitude(1), data.longitude(1), 'HistoryDepth', 10);
            %
            %   % Plot the positions
            %   for i = 1:length(data.latitude)
            %      plotPosition(player, data.latitude(i), data.longitude(i));
            %   end
            %
            %   See also plotRoute
            
            defColor = obj.ColorOrder(1,:);
            params = parsePathParameters(obj, defColor, varargin{:});
            
            % If a path exists, update, else create a new path
            if isvalid(obj.Path)
                obj.Path.update(params);
            else
                obj.addPath(params);
            end
            
            obj.centerMapAroundPath(params.latitude, params.longitude);
            
            % Limit number of updates to the figure
            drawnow('limitrate');
            
        end
        
        function plotMultiObjectPositions(obj, varargin)
            % plotPosition Display current geographic position an object.
            %
            %   plotPosition(player,latitude,longitude) plot position
            %   specified by latitude and longitude, which are scalars in
            %   the range [-90, 90] and [-180, 180], respectively.
            %
            %   plotPosition(...,Name,Value) specifies additional
            %   name-value pair arguments described below:
            %
            %   'Label'         Text description corresponding to the
            %                   current position, specified as a character
            %                   vector or string.
            %
            %                   Default: ''
            %
            %   'Color'         Marker face color, specified as an RGB
            %                   triplet, a character vector or a color
            %                   name. An RGB triplet is a three-element row
            %                   vector whose elements specify the
            %                   intensities of the red, green, and blue
            %                   components of the color. The intensities
            %                   must be in the range [0,1]. Color is only
            %                   used for filled marker symbols.
            %
            %                   Default: Color is selected automatically
            %
            %   'Marker'        Marker symbol for current position,
            %                   specified as one of the following values:
            %
            %                   .   point   x  x-mark     ^ triangle (up)
            %                   o   circle  d  diamond    v triangle (down)
            %                   +   plus    p  pentagram  < triangle (left)
            %                   *   star    h  hexagram   > triangle (right)
            %                   s   square
            %
            %                   Default: 'o' (circle)
            %
            %   'MarkerSize'    Approximate diameter of the position
            %                   marker, specified as a positive value in
            %                   points.
            %
            %                   Default: 6
            %
            %
            %   Notes
            %   -----
            %   - geoplayer automatically updates the map limits to display
            %     new positions added by plotPosition.
            %
            %
            %   Example - View vehicle's current position
            %   -------------------------------------------
            %
            %   % Load data for the route
            %   data = load('geoRoute.mat');
            %
            %   % Initialize the player to view last 10 positions
            %   player = geoplayer(data.latitude(1), data.longitude(1), 'HistoryDepth', 10);
            %
            %   % Plot the positions
            %   for i = 1:length(data.latitude)
            %      plotPosition(player, data.latitude(i), data.longitude(i));
            %   end
            %
            %   See also plotRoute
            
            defColor = obj.ColorOrder(1,:);
            params = parsePathParameters(obj, defColor, varargin{:});
            
            % If a path exists, update, else create a new path
            if isvalid(obj.Path)
                obj.Path.update(params);
            else
                obj.addPath(params);
            end
            
            obj.centerMapAroundPath(params.latitude, params.longitude);
            
            % Limit number of updates to the figure
            drawnow('limitrate');
            
        end
        
        function plotRoute(obj, varargin)
            % plotRoute Display a series of points as a route.
            %
            %   plotRoute(player,latitude,longitude) displays a route in
            %   the player using the data in vectors latitude and
            %   longitude. Specify these values in the range [-90, 90] and
            %   [-180, 180], respectively.
            %
            %   plotRoute(...,Name,Value) specifies additional name-value
            %   pair arguments described below:
            %
            %   'Color'         Line color, specified as an RGB triplet, a
            %                   character vector or a color name. An RGB
            %                   triplet is a three-element row vector whose
            %                   elements specify the intensities of the
            %                   red, green, and blue components of the
            %                   color. The intensities must be in the range
            %                   [0,1].
            %
            %                   Default: Color is selected automatically
            %
            %   'LineWidth'     Line width, specified as a positive value
            %                   in points.
            %
            %                   Default: 2
            %
            %   'ShowEndpoints' Set to 'on' to display the origin and
            %                   destination points when plotting the route.
            %                   The origin marker is white and the
            %                   destination marker is filled with color.
            %
            %                   Default: 'on'
            %
            %   Example - View a vehicle's position along a route
            %   -------------------------------------------------
            %
            %   % Load data for the route
            %   data = load('geoRoute.mat');
            %
            %   % Initialize the player
            %   player = geoplayer(data.latitude(1), data.longitude(1));
            %
            %   % Plot the route
            %   plotRoute(player, data.latitude, data.longitude);
            %
            %   See also plotPosition
            
            % Determine the next default color from color order
            routeNum = mod(numel(obj.Routes), size(obj.ColorOrder,1)) + 1;
            defColor = obj.ColorOrder(routeNum, :);
            
            params = obj.parseRouteParameters(defColor, varargin{:});
            
            obj.Routes(end+1) = driving.internal.geo.PlayerRoute( ...
                obj.Chart, params);
            
        end
        
        function plotMultiRoute(obj, varargin)
            % plotRoute Display a series of points as a route.
            %
            %   plotRoute(player,latitude,longitude) displays a route in
            %   the player using the data in vectors latitude and
            %   longitude. Specify these values in the range [-90, 90] and
            %   [-180, 180], respectively.
            %
            %   plotRoute(...,Name,Value) specifies additional name-value
            %   pair arguments described below:
            %
            %   'Color'         Line color, specified as an RGB triplet, a
            %                   character vector or a color name. An RGB
            %                   triplet is a three-element row vector whose
            %                   elements specify the intensities of the
            %                   red, green, and blue components of the
            %                   color. The intensities must be in the range
            %                   [0,1].
            %
            %                   Default: Color is selected automatically
            %
            %   'LineWidth'     Line width, specified as a positive value
            %                   in points.
            %
            %                   Default: 2
            %
            %   'ShowEndpoints' Set to 'on' to display the origin and
            %                   destination points when plotting the route.
            %                   The origin marker is white and the
            %                   destination marker is filled with color.
            %
            %                   Default: 'on'
            %
            %   Example - View a vehicle's position along a route
            %   -------------------------------------------------
            %
            %   % Load data for the route
            %   data = load('geoRoute.mat');
            %
            %   % Initialize the player
            %   player = geoplayer(data.latitude(1), data.longitude(1));
            %
            %   % Plot the route
            %   plotRoute(player, data.latitude, data.longitude);
            %
            %   See also plotPosition
            
            % Determine the next default color from color order
            routeNum = mod(numel(obj.Routes), size(obj.ColorOrder,1)) + 1;
            defColor = obj.ColorOrder(routeNum, :);
            
            params = obj.parseRouteParameters(defColor, varargin{:});
            
            obj.Routes(end+1) = driving.internal.geo.PlayerRoute( ...
                obj.Chart, params);
            
        end
        
        function reset(obj)
            % RESET Remove all data from the player.
            %
            %   RESET(player) removes all previously plotted points and
            %   routes from the player.
            %
            %   See also plotRoute, plotPosition
            
            delete(obj.Routes);
            delete(obj.Path);
            
            obj.Routes = driving.internal.geo.PlayerRoute.empty;
            obj.Path = driving.internal.geo.PlayerPath.empty;
            
        end
        
        function show(obj)
            % SHOW Make the player figure window visible.
            %
            %   See also HIDE, isOpen
            if isgraphics(obj.Parent, 'figure')
                figure(obj.Parent)
            elseif isgraphics(obj.Parent)
                obj.Parent.Visible = 'on';
            end
            drawnow;
        end
        
        function hide(obj)
            % HIDE Make the player figure window invisible.
            %
            %   See also SHOW, isOpen
            if isgraphics(obj.Parent)
                obj.Parent.Visible = 'off';
            end
            drawnow;
        end
        
        function tf = isOpen(obj)
            % isOpen Check if the player window is open.
            %
            %   tf = isOpen(player) checks if the player figure window is open.
            %   The method returns true if the window is open and false
            %   otherwise.
            %
            %   See also SHOW, HIDE
            
            if isvalid(obj.Chart) && strcmpi(obj.Parent.Visible, 'on')
                tf = true;
            else
                tf = false;
            end
            
        end
        
    end
    
    methods(Access = private)
        
        % Create the geographic chart object
        createChart(obj, params)
        
        % Initialize the player properties and base chart object
        function initializePlayer(obj, params)
            
            % Initialize object properties
            obj.HistoryDepth = params.HistoryDepth;
            obj.HistoryStyle = params.HistoryStyle;
            
            % Create the simple geographic chart
            obj.createChart(params);
            
        end
        
        % Create a new path
        function addPath(obj, params)
            
            obj.Path = driving.internal.geo.PlayerPath(obj.Chart, params);
            
            if obj.HistoryDepth
                
                obj.Path.addHistory(params.latitude, params.longitude, ...
                    obj.HistoryDepth, obj.HistoryStyle);
                
            end
            
        end
        
        % Recenter the player display if path is out of view
        function centerMapAroundPath(obj, latitude, longitude)
            
            % Check if the data exceeds the visible chart boundaries
            isOutOfBounds = ~inpolygon(longitude, latitude, ...
                obj.Chart.LongitudeLimits, obj.Chart.LatitudeLimits);
            isValidCenter = abs(latitude) < 90 && abs(longitude) < 180;
            
            % If data is out of bounds, move map center to given position
            if isOutOfBounds && isValidCenter
                obj.MapCenter = [latitude, longitude];
            end
            
        end
        
        % Parse and validate geoplayer inputs
        function params = parsePlayerParameters(~, varargin)
            
            parser = inputParser;
            parser.FunctionName = mfilename;
            
            defaults = struct(...
                'HistoryDepth', 0, ...
                'HistoryStyle', 'point', ...
                'Parent', '', ...
                'ZoomLevel', 15, ...
                'Basemap', 'streets');
            
            % Required input argument
            parser.addRequired('latCenter', ...
                @(x)geoplayer.validateLatCenter(x));
            parser.addRequired('lonCenter', ...
                @(x)geoplayer.validateLongitude(x));
            
            % Optional input arguments
            parser.addOptional('ZoomLevel', defaults.ZoomLevel, ...
                @(x)geoplayer.validateZoomLevel(x));
            
            % Optional name-value pairs
            parser.addParameter('HistoryStyle', defaults.HistoryStyle);
            parser.addParameter('HistoryDepth', defaults.HistoryDepth, ...
                @(x)geoplayer.validateHistoryDepth(x));
            parser.addParameter('Parent', defaults.Parent, ...
                @(x)geoplayer.validateParent(x));
            
            % The basemap is validated by the chart
            parser.addParameter('Basemap', defaults.Basemap);
            
            % Parse and return results
            parser.parse(varargin{:});
            params = parser.Results;
            
            % Validate and return matched style string
            params.HistoryStyle = geoplayer.validateAndMatchHistoryStyle(params.HistoryStyle);
            
        end
        
        % Parse and validate plotPosition parameters
        function params = parsePathParameters(obj, defColor, varargin)
            
            % Set defaults equal to path params, if one already exists
            if isvalid(obj.Path)
                defaults = struct(...
                    'Color', obj.Path.Color, ...
                    'Marker', obj.Path.Marker, ...
                    'MarkerSize', obj.Path.MarkerSize, ...
                    'Label', obj.Path.LabelStr);
            else
                defaults = struct(...
                    'Color', defColor, ...
                    'Marker', 'o', ...
                    'MarkerSize', 6, ...
                    'Label', '');
            end
            
            parser = inputParser;
            parser.FunctionName = mfilename;
            
            % Required input arguments
            parser.addRequired('latitude', ...
                @(x)geoplayer.validateLatitude(x));
            parser.addRequired('longitude', ...
                @(x)geoplayer.validateLongitude(x));
            
            % Optional name-value pairs
            parser.addParameter('Color', defaults.Color);
            parser.addParameter('Marker', defaults.Marker, ...
                @(x)geoplayer.validateMarker(x));
            parser.addParameter('MarkerSize', defaults.MarkerSize, ...
                @(x)geoplayer.validateMarkerSize(x));
            parser.addParameter('Label', defaults.Label, ...
                @(x)geoplayer.validateLabel(x));
            
            % Parse and return results
            parser.parse(varargin{:});
           params = parser.Results;
            
            % Validate and convert ColorSpec strings to RGB
            params.Color = geoplayer.validateAndConvertColorToRGB(params.Color);
            
        end
        
        % Parse and validate plotRoute parameters
        function params = parseRouteParameters(~, defColor, varargin)
            
            % Lighten default route colors
            defColor = [1 1 1] - ([1 1 1] - defColor) / 1.35;
            
            defaults = struct( ...
                'Color', defColor, ...
                'LineWidth', 2, ...
                'ShowEndpoints', 'on');
            
            parser = inputParser;
            parser.FunctionName = mfilename;
            
            % Required input arguments
            parser.addRequired('latitude', ...
                @(x)geoplayer.validateLatitudeVector(x));
            parser.addRequired('longitude', ...
                @(x)geoplayer.validateLongitudeVector(x));
            
            % Optional name-value pairs
            parser.addParameter('Color', defaults.Color);
            parser.addParameter('ShowEndpoints', defaults.ShowEndpoints);
            parser.addParameter('LineWidth', defaults.LineWidth, ...
                @(x)geoplayer.validateLineWidth(x));
            
            % Parse and return results
            parser.parse(varargin{:});
            params = parser.Results;
            
            % Validate and convert ColorSpec strings to RGB
            params.Color = geoplayer.validateAndConvertColorToRGB(params.Color);
            
            % Validate and convert chars and strings to OnOff enum
            params.ShowEndpoints = matlab.lang.OnOffSwitchState(params.ShowEndpoints);
            
        end
        
    end
    
    methods(Hidden)
        
        function sObj = saveobj(obj)
            
            sObj.MapCenter = obj.MapCenter;
            sObj.ZoomLevel = obj.ZoomLevel;
            
            sObj.HistoryDepth = obj.HistoryDepth;
            sObj.HistoryStyle = obj.HistoryStyle;
            sObj.Basemap = obj.Basemap;
            
            sObj.Version = obj.Version;
            
        end
        
    end
    
    methods(Hidden, Static)
        
        function obj = loadobj(sObj)
            obj = geoplayer(...
                sObj.MapCenter(1), sObj.MapCenter(2), sObj.ZoomLevel, ...
                'HistoryDepth', sObj.HistoryDepth, ...
                'HistoryStyle', sObj.HistoryStyle, ...
                'Basemap', sObj.Basemap);
        end
        
        % Latitude for map center  must be a real, numeric value in the
        % range (-latBound, latBound).
        function validateLatCenter(lat)
            latBound = 90;
            validateattributes(lat, {'double','single'}, ...
                {'real','scalar','finite','>',-latBound,'<',latBound});
        end
        
        % Latitude must be a real, numeric value in the range [-90, 90].
        function validateLatitude(lat)
            validateattributes(lat, {'double','single'}, ...
                {'real','nonsparse'});
            geoplayer.validateGeographicRange(lat, 90);
        end
        
        function validateLatitudeVector(lat)
            validateattributes(lat, {'double','single'}, ...
                {'real','nonsparse','vector'});
            geoplayer.validateGeographicRange(lat, 90);
        end
        
        % Longitude must be a real, numeric value in the range [-180, 180].
        function validateLongitude(lon)
            validateattributes(lon, {'double','single'}, ...
                {'real','nonsparse','vector'});
            geoplayer.validateGeographicRange(lon, 180);
        end
        
        function validateLongitudeVector(lon)
            validateattributes(lon, {'double','single'}, ...
                {'real','nonsparse','vector'});
            geoplayer.validateGeographicRange(lon, 180);
        end
        
        % Geographic coordinates must be finite and in the range given by
        % [-dataBound, dataBound]. NaN values are allowed.
        function validateGeographicRange(data, dataBound)
            
            if any(isinf(data))
                validateattributes(data, {'numeric'}, ...
                    {'finite'});
            else
                validateattributes(data(~isnan(data)), {'numeric'}, ...
                    {'>=',-dataBound,'<=',dataBound});
            end
            
        end
        
        % Verify zoom level is an integer value between 0 and 25.
        function validateZoomLevel(zoomLevel)
            validateattributes(zoomLevel, {'numeric'}, ...
                {'scalar','real','integer','>=',0,'<=',25});
        end
        
        % Verify historyDepth is an integer value between 0 and Inf.
        function validateHistoryDepth(historyDepth)
            validateattributes(historyDepth, {'numeric'}, ...
                {'scalar','real', 'nonnegative'});
        end
        
        % HistoryStyle must be a scalar string options as specified by
        % validHistoryStyles
        function validStyle = validateAndMatchHistoryStyle(historyStyle)
            validStyle = validatestring(historyStyle, {'point','line'}, ...
                mfilename, 'HistoryStyle');
        end
        
        % Parent must be a scalar handle to an object of the classes
        % specified by validParentClasses
        function validateParent(parent)
            validParentClasses = { ...
                'matlab.ui.Figure', ...
                'matlab.ui.container.Panel'};
            
            if ~any(strcmpi(class(parent), validParentClasses)) || ~isscalar(parent)
                error(message('driving:geoplayer:validParent'));
            end
        end
        
        % Color must be either a char or string of the expected options
        % or a 1-by-3 vector with values between 0 and 1.
        function color = validateAndConvertColorToRGB(color)
            if ischar(color) || isstring(color)
                validateattributes(color, {'char', 'string'}, ...
                    {'nonempty', 'vector'});
                
                specOptions = {
                    'red','green','blue','yellow','magenta','cyan',...
                    'white','black','r','g','b','y','m','c','w','k'};
                
                rgbOptions = [1 0 0; 0 1 0; 0 0 1; 1 1 0; ...
                    1 0 1; 0 1 1; 1 1 1; 0 0 0];
                rgbOptions = repmat(rgbOptions, [2 1]);
                
                % Find best match for the given color string
                color = validatestring(color, specOptions);
                
                index = strcmp(color, specOptions);
                color = rgbOptions(index,:);
            else
                validateattributes(color, {'double'}, ...
                    {'nonempty', '>=', 0, '<=', 1, 'size', [1 3]});
            end
        end
        
        % LineWidth must be a positive numeric value
        function validateLineWidth(lineWidth)
            validateattributes(lineWidth, {'numeric'}, ...
                {'scalar', 'positive', 'finite'});
        end
        
        % Value must be a scalar string or char
        function validateLabel(label)
            validateattributes(label, {'char', 'string'}, ...
                {'scalartext'});
        end
        
        % Marker must be char or string specified as acceptable marker
        function validateMarker(marker)
            validateattributes(marker, {'char', 'string'}, ...
                {'scalartext'});
            
            validMarkerStyles = {'o','+','*','.','x','s','d', ...
                '^','v','>','<','p','h', ....
                'square','diamond','pentagram','hexagram'};
            validatestring(marker, validMarkerStyles,mfilename,'Marker');
            
        end
        
        % Marker size must be a scalar positive numeric
        function validateMarkerSize(markerSize)
            validateattributes(markerSize, {'numeric'}, ...
                {'scalar','positive','finite'});
        end
        
    end
    
end