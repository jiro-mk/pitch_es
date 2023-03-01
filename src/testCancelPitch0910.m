% TESTCANCELPITCH: This example is based on the example of Video 
% Stabilization Using Point Feature Matching
% Please look at 
% web(fullfile(docroot, 'vision/examples/video-stabilization-using-point-feature-matching.html?s_tid=doc_srchtitle'))
%   Copyright 2019 The MathWorks, Inc.

%% Define directory including sub directory of scene images
sampleDirPath = outputDirectoryPathInSlProj('pitchcheck0911');
folderNames = dir(sampleDirPath);
folderNames = folderNames(3:end);
folderNames = string({folderNames.name});



%% Start simulation
for iFile = 3%:numel(folderNames)
    
    initialframe=187;%変化し始めるフレーム
    
    
    % Use imageDatastore to handle the scene images
    sampleSubDirName = folderNames(iFile);
    imds = imageDatastore(fullfile(sampleDirPath, sampleSubDirName),'IncludeSubfolders',true);
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

%     
    tb=table;
    
    tb1=table;

    uu1=0;
    outputVideo = VideoWriter('test3111.avi');
    outputVideo.FrameRate = 14;
    open(outputVideo)
    % Process all frames in the video
    movMean = rgb2gray(imread(imds.Files{1}));
    imgB = movMean;
    imgBp = imgB;
    correctedMean = imgBp;
    Hcumulative = eye(3);
    
    
    for i = 1:initialframe-1
        I=imread((imds.Files{i}));
        % Read in new frame
        imgA = imgB;                 % z^-1
        imgAp = imgBp;               % z^-1
        imgB = rgb2gray(imread(imds.Files{i}));
        movMean = movMean + imgB;
        
        
        ptThresh = 0.1;
%         pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh,'ROI', [1,1,1279,660]);
%         pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh,'ROI', [1,1,1279,660]);
        pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh,'ROI', [1,1,847,420]);%右下TUATの名前の部分以外を見る。イメージサイズによって変更。
        pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh,'ROI', [1,1,847,420]);
        
        [featuresA, pointsA] = extractFeatures(imgA, pointsA);
        [featuresB, pointsB] = extractFeatures(imgB, pointsB);

        
        indexPairs = matchFeatures(featuresA, featuresB);
        pointsA = pointsA(indexPairs(:, 1), :);
        pointsB = pointsB(indexPairs(:, 2), :);
        
        if size(pointsA,1)<=2
        continue
        end
        
        if size(pointsB,1)<=2
        continue
        end
        [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
        pointsB, pointsA, 'projective','MaxNumTrials',3000);
        imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        pointsBmp = transformPointsForward(tform, pointsBm.Location);

        % Estimate transform from frame A to frame B, and fit as an s-R-t
        H = tform.T;


        % Only compensate for y-axis difference
        H(1:2, 1:2) = [1 0; 0 1];
        H(3, 1) = 0;
        [HsRt,s,ang] = cvexTformToSRT(H);
%          Hcumulative = HsRt * Hcumulative;
        Hcumulative = HsRt ;
        imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

        

        mmm=pointsAm.Location(:,2)-pointsBm.Location(:,2);
        mmm1=rmoutliers(mmm);%外れ値除去
        
        f=527.8;%pix焦点距離
        u=atan(mmm/f);
        u1=atan(mmm1/f);

        uu=mean(rad2deg(u));
        uu1=mean(rad2deg(u1));
        
        tb(end + 1, :) = table(uu);
        tb1(end + 1, :) = table(uu1);
        % Display as color composite with last corrected frame
        step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'));
        correctedMean = correctedMean + imgBp;
        %writeVideo(outputVideo,I)
         writeVideo(outputVideo, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'))
    end

    
    %%
    for i = 1:numImFiles
        I=imread((imds.Files{i}));
        % Read in new frame
%         imgA = imgB;                 % z^-1
%         imgAp = imgBp;               % z^-1

        imgA=rgb2gray(imread(imds.Files{1}));%最初のフレームと比べる
        imgAp = imgA;
        
        imgB = rgb2gray(imread(imds.Files{i}));
        movMean = movMean + imgB;
        

        
        ptThresh = 0.1;
%         pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh,'ROI', [1,1,1279,660]);
%         pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh,'ROI', [1,1,1279,660]);
        pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh,'ROI', [1,1,847,420]);
        pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh,'ROI', [1,1,847,420]);
        
        [featuresA, pointsA] = extractFeatures(imgA, pointsA);
        [featuresB, pointsB] = extractFeatures(imgB, pointsB);

        
        indexPairs = matchFeatures(featuresA, featuresB);
        pointsA = pointsA(indexPairs(:, 1), :);
        pointsB = pointsB(indexPairs(:, 2), :);
        
        if size(pointsA,1)<=2
        continue
        end
        
        if size(pointsB,1)<=2
        continue
        end
        [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
        pointsB, pointsA, 'projective','MaxNumTrials',3000);
        imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
        pointsBmp = transformPointsForward(tform, pointsBm.Location);

        % Estimate transform from frame A to frame B, and fit as an s-R-t
        H = tform.T;


        % Only compensate for y-axis difference
        H(1:2, 1:2) = [1 0; 0 1];
        H(3, 1) = 0;
        [HsRt,s,ang] = cvexTformToSRT(H);
%          Hcumulative = HsRt * Hcumulative;
         Hcumulative = HsRt ;
        imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

        

        mmm=pointsAm.Location(:,2)-pointsBm.Location(:,2);
        mmm1=rmoutliers(mmm);%外れ値除去
        
        f=527.8;%pix焦点距離
        u=atan(mmm/f);
        u1=atan(mmm1/f);

        uu=mean(rad2deg(u));
        uu1=mean(rad2deg(u1));
        
        tb(end + 1, :) = table(uu);
        tb1(end + 1, :) = table(uu1);
        % Display as color composite with last corrected frame
        step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'));
        correctedMean = correctedMean + imgBp;
        %writeVideo(outputVideo,I)
         writeVideo(outputVideo, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'))
    end

% figure; imshowpair(movMean, correctedMean, 'montage');
% title(['Raw input mean', repmat(' ', [1 50]), 'Corrected sequence mean']);
% pause(10)

end


%  tb.uu = tb.uu*-1;
%  tb1.uu1 = tb1.uu1*-1;

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
plot(tb.uu)
hold on
plot(tb1.uu1)

scatter(x,gt,'filled')
hold on
scatter(x,tb1.uu1,'filled')
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