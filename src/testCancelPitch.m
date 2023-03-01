% TESTCANCELPITCH: This example is based on the example of Video 
% Stabilization Using Point Feature Matching
% Please look at 
% web(fullfile(docroot, 'vision/examples/video-stabilization-using-point-feature-matching.html?s_tid=doc_srchtitle'))
%   Copyright 2019 The MathWorks, Inc.

%% Define directory including sub directory of scene images
sampleDirPath = outputDirectoryPathInSlProj('Samples');
folderNames = dir(sampleDirPath);
folderNames = folderNames(3:end);
folderNames = string({folderNames.name});

%% Start simulation
for iFile = 10%:numel(folderNames)

    % Use imageDatastore to handle the scene images
    sampleSubDirName = folderNames(iFile);
    imds = imageDatastore(fullfile(sampleDirPath, sampleSubDirName));
    numImFiles = length(imds.Files);

    %% Video Stabilization Using Point Feature Matching
    % This example shows how to stabilize a video that was captured from a
    % jittery platform. One way to stabilize a video is to track a salient
    % feature in the image and use this as an anchor point to cancel out all
    % perturbations relative to it. This procedure, however, must be
    % bootstrapped with knowledge of where such a salient feature lies in the
    % first video frame. In this example, we explore a method of video
    % stabilization that works without any such _a priori_ knowledge. It
    % instead automatically searches for the "background plane" in a video
    % sequence, and uses its observed distortion to correct for camera motion.
    %
    % This stabilization algorithm involves two steps. First, we determine the
    % affine image transformations between all neighboring frames of a video
    % sequence using the | estimateGeometricTransform | function applied to point
    % correspondences between two images. Second, we warp the video frames to
    % achieve a stabilized video. We will use the Computer Vision System
    % Toolbox(TM), both for the algorithm and for display.
    %
    % This example is similar to the <video-stabilization.html Video Stabilization
    % Example>. The main difference is that the Video Stabilization Example is
    % given a region to track while this example is given no such knowledge.
    % Both examples use the same video.

    %  Copyright 2009-2014 The MathWorks, Inc.

    %% Step 6. Run on the Full Video
    % Now we apply the above steps to smooth a video sequence. For readability, 
    % the above procedure of estimating the transform between two images has
    % been placed in the MATLAB(R) function
    % <matlab:edit(fullfile(matlabroot, 'toolbox', 'vision', 'visiondemos', 'cvexEstStabilizationTform.m')) | cvexEstStabilizationTform | >.
    % The function
    % <matlab:edit(fullfile(matlabroot, 'toolbox', 'vision', 'visiondemos', 'cvexTformToSRT.m')) | cvexTformToSRT | >
    % also converts a general affine transform into a
    % scale-rotation-translation transform.
    %
    % At each step we calculate the transform $H$ between the present frames.
    % We fit this as an s-R-t transform, $H_{sRt}$. Then we combine this the
    % cumulative transform, $H_{cumulative}$, which describes all camera motion
    % since the first frame. The last two frames of the smoothed video are
    % shown in a Video Player as a red-cyan composite.
    %
    % With this code, you can also take out the early exit condition to make
    % the loop process the entire video.

    hVPlayer = vision.VideoPlayer;   % Create video viewer
    hVPlayer.Position(3:4) = [1575 796];

    

outputVideo = VideoWriter('test3.avi');
outputVideo.FrameRate = 14;
open(outputVideo)
    % Process all frames in the video
    movMean = rgb2gray(imread(imds.Files{1}));
    imgB = movMean;
    imgBp = imgB;
    correctedMean = imgBp;
    Hcumulative = eye(3);
    for i = 1:numImFiles-1
        I=imread((imds.Files{i}));
        % Read in new frame
        imgA = imgB;                 % z^-1
        imgAp = imgBp;               % z^-1
        imgB = rgb2gray(imread(imds.Files{i}));
        movMean = movMean + imgB;

        % Estimate transform from frame A to frame B, and fit as an s-R-t
        H = cvexEstStabilizationTform(imgA, imgB);

        % Only compensate for y-axis difference
%         H(1:2, 1:2) = [1 0; 0 1];
%         H(3, 1) = 0;
        HsRt = cvexTformToSRT(H);
        Hcumulative = HsRt * Hcumulative;
        imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

        
        % Display as color composite with last corrected frame
        step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'));
        correctedMean = correctedMean + imgBp;
        %writeVideo(outputVideo,I)
         writeVideo(outputVideo, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'))
    end
    correctedMean = correctedMean/(i-2);

    movMean = movMean/(i-2);

% figure; imshowpair(movMean, correctedMean, 'montage');
% title(['Raw input mean', repmat(' ', [1 50]), 'Corrected sequence mean']);
% pause(10)

end
close(outputVideo)
%%
% During computation, we computed the mean of the raw video frames and of
% the corrected frames. These mean values are shown side-by-side below. The
% left image shows the mean of the raw input frames, proving that there was
% a great deal of distortion in the original video. The mean of the
% corrected frames on the right, however, shows the image core with almost
% no distortion. While foreground details have been blurred (as a necessary
% result of the car's forward motion), this shows the efficacy of the
% stabilization algorithm.

release(hVPlayer);

%% References
% [1] Tordoff, B; Murray, DW. "Guided sampling and consensus for motion
% estimation." European Conference n Computer Vision, 2002.
%
% [2] Lee, KY; Chuang, YY; Chen, BY; Ouhyoung, M. "Video Stabilization
% using Robust Feature Trajectories." National Taiwan University, 2009.
%
% [3] Litvin, A; Konrad, J; Karl, WC. "Probabilistic video stabilization
% using Kalman filtering and mosaicking." IS & T/SPIE Symposium on Electronic
% Imaging, Image and Video Communications and Proc., 2003.
%
% [4] Matsushita, Y; Ofek, E; Tang, X; Shum, HY. "Full-frame Video
% Stabilization." Microsoft(R) Research Asia. CVPR 2005.