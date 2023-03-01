% TESTCANCELPITCH: This example is based on the example of Video 
% Stabilization Using Point Feature Matching
% Please look at 
% web(fullfile(docroot, 'vision/examples/video-stabilization-using-point-feature-matching.html?s_tid=doc_srchtitle'))
%   Copyright 2019 The MathWorks, Inc.

%% Define directory including sub directory of scene images
%  sampleDirPath = outputDirectoryPathInSlProj('pitchcheck0911');
 sampleDirPath = outputDirectoryPathInSlProj('Samples');
folderNames = dir(sampleDirPath);
folderNames = folderNames(3:end);
folderNames = string({folderNames.name});



dirPath = outputDirectoryPathInSlProj('cameraParameters');
fileList = dir(fullfile(dirPath,'*.mat'));

%デンソーテン製カメラ
tmp = load(fileList(1).name);
camParams = tmp.cameraParams;

focalLength    = camParams.FocalLength;      % [fx, fy] in pixel units
principalPoint = camParams.PrincipalPoint;   % [cx, cy] optical center in pixel coordinates
imageSize      = camParams.ImageSize;        % [nrows, mcols]
radialDistortion = camParams.RadialDistortion;

f=focalLength(1);

%%
f=370;
imageSize      = [400 640];
%% Start simulation
for iFile = 4%:numel(folderNames)
    
    % Use imageDatastore to handle the scene images
    sampleSubDirName = folderNames(iFile);
    imds = imageDatastore(fullfile(sampleDirPath, sampleSubDirName),'IncludeSubfolders',true);
    numImFiles = length(imds.Files);

    
    
    %% トリガの位置をCSVから読み取る
      a= dir(fullfile(sampleDirPath, sampleSubDirName, 'ID*.csv'));
%      a= dir(fullfile(sampleDirPath, sampleSubDirName, '*.csv'));
    DR=readtable(a.name);
    DR_event=table2array(DR(:,13));
    
    triggerframe = find(strncmp('true', DR_event,4));%トリガのフレーム
    
%      switchframe=index;%変化し始めるフレーム
    

    tb=table;
        tbp=table;
    tb1=table;
    uu=0;
    uu1=0;
vv=0;
    
    
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

%     hVPlayer = vision.VideoPlayer;   % Create video viewer
%     hVPlayer.Position(3:4) = [1575 796];

%     

%     outputVideo = VideoWriter('test3111.avi');
%     outputVideo.FrameRate = 14;
%     open(outputVideo)
    % Process all frames in the video
    movMean = rgb2gray(imread(imds.Files{1}));
    imgB = movMean;
    imgBp = imgB;
    correctedMean = imgBp;
    Hcumulative = eye(3);
    
    
    for i = 1: numImFiles%switchframe-1
        I=imread((imds.Files{i}));
        % Read in new frame
        imgA = imgB;                 % z^-1
        imgAp = imgBp;               % z^-1
        imgB = rgb2gray(imread(imds.Files{i}));
        movMean = movMean + imgB;
        
        
        ptThresh = 0.1;
%          pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh,'ROI', [1,1,imageSize(2)-1,imageSize(1)-60]);%右下TUATの名前の部分以外で特徴点を探す
%          pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh,'ROI', [1,1,imageSize(2)-1,imageSize(1)-60]);
          pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh,'ROI', [1,1,847,420]);%インプレッサ実験用
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
%         mmm1=rmoutliers(mmm);%外れ値除去
       v= atan((abs(pointsBm.Location(:,2)-pointsAm.Location(:,2)))./(abs(pointsBm.Location(:,1)-pointsAm.Location(:,1))));
       v=rad2deg(v);
       vv=nanmean(v);
  
        u=atan(mmm/f);
%         u1=atan(mmm1/f);
        pitchrate=mean(rad2deg(u));
        uu=mean(rad2deg(u));
%         uu1=mean(rad2deg(u1));
        tbp(end + 1, :) = table(pitchrate);
        tb(end + 1, :) = table(uu);
%         tb1(end + 1, :) = table(uu1);
        
        % Display as color composite with last corrected frame
%         step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'));
        correctedMean = correctedMean + imgBp;
        %writeVideo(outputVideo,I)
%          writeVideo(outputVideo, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'))
    end

%%  蓄積誤差を小さくするために変化し始めるフレームを探す

%      e=movmean(tb.uu,3);%移動平均.3フレーム間.この処理やらんくていいかも
     e=tb.uu;
     e(1:triggerframe)=0;%トリガ後からのピークを探すため、それ以前を0に
     ee=abs(e);
    [pks,locs] = findpeaks(ee,'SortStr','descend','NPeaks',1);%最大変化ピッチ角のフレーム
    TF = islocalmin(ee);
    k=find(TF);
    Idx=knnsearch(k,locs,'K',2);
    Idx=sort(k(Idx));
    Idx=Idx(1);
    switchframe=Idx-1;  
       switchframe=triggerframe-30*1.5;%トリガの1.5s前
       switchframe=192;%前後加速度の減少はじめ
%     B = flipud(ee);
%     [Idx,d]=knnsearch(B(numImFiles-locs+1:numImFiles-triggerframe),0,'K',1);%最大変化し始めるフレームを探す
%     switchframe=locs-Idx+1;    
    
    
    tb([switchframe:end],:)=[];
    tb1([switchframe:end],:)=[];
    movMean = rgb2gray(imread(imds.Files{switchframe}));
    imgB = movMean;
    imgBp = imgB;
    correctedMean = imgBp;
    Hcumulative = eye(3);
    %%
    for i = switchframe:numImFiles
        I=imread((imds.Files{i}));
        % Read in new frame
        imgA = imgB;                 % z^-1
        imgAp = imgBp;               % z^-1

%         imgA=rgb2gray(imread(imds.Files{initialframe}));%最初のフレームと比べる
%         imgAp = imgA;
        
        imgB = rgb2gray(imread(imds.Files{i}));
        movMean = movMean + imgB;
        

        
        ptThresh = 0.1;
%          pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh,'ROI', [1,1,imageSize(2)-1,imageSize(1)-60]);%右下TUATの名前の部分以外で特徴点を探す
%          pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh,'ROI', [1,1,imageSize(2)-1,imageSize(1)-60]);
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
%         mmm1=rmoutliers(mmm);%外れ値除去
         v= atan((abs(pointsBm.Location(:,2)-pointsAm.Location(:,2)))./(abs(pointsBm.Location(:,1)-pointsAm.Location(:,1))));
       v=rad2deg(v);
       vv=nanmean(v);
        u=atan(mmm/f);
%         u1=atan(mmm1/f);
        

        uu=uu+mean(rad2deg(u));
%         uu1=uu1+mean(rad2deg(u1));
        
        tb(end + 1, :) = table(uu);
%         tb1(end + 1, :) = table(uu1);
        % Display as color composite with last corrected frame
%         step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'));
        correctedMean = correctedMean + imgBp;
        %writeVideo(outputVideo,I)
%          writeVideo(outputVideo, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'))
    end

% figure; imshowpair(movMean, correctedMean, 'montage');
% title(['Raw input mean', repmat(' ', [1 50]), 'Corrected sequence mean']);
% pause(10)

end
%%
figure()
plot(tb.uu)
hold on
scatter(triggerframe,tb.uu(triggerframe),'filled')
hold on
scatter(switchframe,tb.uu(switchframe),'filled')


legend('Pitch','Trigger frame','Switch frame')
xlabel('Frame');
ylabel('Pitch [deg]');

xu=[0:1/14:293/14];
% xu(end)=[];



figure()
plot(xu,tb.uu)%deg vs time
hold on
scatter(xu(triggerframe),tb.uu(triggerframe),'filled')
hold on
scatter(xu(switchframe),tb.uu(switchframe),'filled')


legend('Pitch','Trigger frame','Switch frame')
xlabel('Time [s]');
ylabel('Pitch [deg]');
%% エクセル読み込み、プロット

IMU= dir(fullfile(sampleDirPath, sampleSubDirName, '*.csv'));
IMU=IMU(1);
IMU=readtable(IMU.name);
IMU_pitch=table2array(IMU(:,19))*-1;
IMU_pitchrate=table2array(IMU(:,22))*-1;
% figure()
% plot(IMU_pitch)%フレームとピッチ

xi=[0:0.01:size(IMU_pitch,1)*0.01-0.01];
figure()
plot(xi,IMU_pitch)%秒とピッチ

xlim([0 xu(end)])

legend('Pitch','Trigger frame','Switch frame')
xlabel('Time [s]');
ylabel('Pitch [deg]');
%%
% xu=[0:1/14:293/14];%ドラレコx軸。秒
% nn=xu(switchframe);%スイッチフレームを基準にする
% nnn=knnsearch(xi',nn,'K',1);%IMUにおけるスイッチのときのフレーム
% offset=IMU_pitch(nnn);%IMUにおいてのスイッチ時間
[DRmin,DRminId]=min(tb.uu);
[IMUmin,IMUminId]=min(IMU_pitch);
del=abs(xu(DRminId)-xi(IMUminId))*100;
IMU_pitch(1:del)=[];%ピークの位置合わせ
IMU_pitchrate(1:del)=[];
xi=[0:0.01:size(IMU_pitch,1)*0.01-0.01];
[IMUmin,IMUminId]=min(IMU_pitch);%最小値のインデックスを更新
DRmin1=tb.uu(round(DRminId-14*1));
IMUmin1=IMU_pitch(IMUminId-100*1);

DRminS=tb.uu(switchframe);
IdxS=knnsearch(xi',xu(switchframe),'K',1);
IMUminS=IMU_pitch(IdxS);

offset=abs(IMUmin-DRmin);
offset1=abs(IMUmin1-DRmin1);
offsetS=abs(IMUminS-DRminS);

figure()
plot(xu,tb.uu)%deg vs time
hold on
plot(xi,IMU_pitch-mean(IMU_pitch))%0.9852)%-offset1)%秒とピッチ
hold on
scatter(xu(triggerframe),tb.uu(triggerframe),'filled')
hold on
scatter(xu(switchframe),tb.uu(switchframe),'filled')

figure()
plot(xu,tbp.pitchrate)
hold on
plot(xi,IMU_pitchrate*0.1)
hold on
scatter(triggerframe,tb.uu(triggerframe),'filled')
hold on
scatter(switchframe,tb.uu(switchframe),'filled')


legend('Pitch','Trigger frame','Switch frame')
xlabel('Frame');
ylabel('Pitch [deg]');

xu=[0:1/14:293/14];

xlim([0 xu(end)])
ylim([-1.5 1.5])
legend('Estimated Pitch','IMU Pitch','Trigger frame','Switch frame')
xlabel('Time [s]');
ylabel('Pitch [deg]');

% e=abs(IMUmin-mean(IMU_pitch)-DRmin)
% tbe(end + 1, :) = table(e);
%% 1秒前からピークまでの変化
% mean(tb.uu([DRminId-14:DRminId],1))
% IMU_pitchoff=IMU_pitch-offset;
% mean(IMU_pitchoff([IMUminId-14:IMUminId],1))


%%

%  tb.uu = tb.uu*-1;
%  tb1.uu1 = tb1.uu1*-1;

% close(outputVideo)
%%
% During computation, we computed the mean of the raw video frames and of
% the corrected frames. These mean values are shown side-by-side below. The
% left image shows the mean of the raw input frames, proving that there was
% a great deal of distortion in the original video. The mean of the
% corrected frames on the right, however, shows the image core with almost
% no distortion. While foreground details have been blurred (as a necessary
% result of the car's forward motion), this shows the efficacy of the
% stabilization algorithm.

% release(hVPlayer);
% figure()
% plot(tb.uu)
% hold on
% plot(tb1.uu1*-1)
% 
% figure()
% scatter(x,gt,'filled')
% hold on
% scatter(x,tb1.uu1,'filled')
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