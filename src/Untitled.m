imgA=rgb2gray(x0000);
imgB=rgb2gray(x0005);

figure; imshowpair(imgA,imgB,'ColorChannels','red-cyan');
title('Color composite (frame A = red, frame B = cyan)');

ptThresh = 0.1;
pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh,'ROI', [1,1,1279,660]);
pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh,'ROI', [1,1,1279,660]);%[1,1,847,420]

% Display corners found in images A and B.
figure; imshow(imgA); hold on;
plot(pointsA);
title('Corners in A');

figure; imshow(imgB); hold on;
plot(pointsB);
title('Corners in B');

% Extract FREAK descriptors for the corners
[featuresA, pointsA] = extractFeatures(imgA, pointsA);
[featuresB, pointsB] = extractFeatures(imgB, pointsB);


indexPairs = matchFeatures(featuresA, featuresB);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);

figure; showMatchedFeatures(imgA, imgB, pointsA, pointsB);
legend('A', 'B');

[tform, pointsBm, pointsAm] = estimateGeometricTransform(...
    pointsB, pointsA, 'projective','MaxNumTrials',3000);
imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
pointsBmp = transformPointsForward(tform, pointsBm.Location);

figure;
showMatchedFeatures(imgA, imgB, pointsAm, pointsBm);
legend('A', 'B');

% Extract scale and rotation part sub-matrix.
H = tform.T;
R = H(1:2,1:2);
% Compute theta from mean of two possible arctangents
theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
% Compute scale from mean of two stable mean calculations
scale = mean(R([1 4])/cos(theta));
% Translation remains the same:
translation = H(3, 1:2);
% Reconstitute new s-R-t transform:

        H(1:2, 1:2) = [1 0; 0 1];
        H(3, 1) = 0;

HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
  translation], [0 0 1]'];
tformsRT = affine2d(HsRt);

imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
imgBsRt = imwarp(imgB, tformsRT, 'OutputView', imref2d(size(imgB)));

figure(2), clf;
imshowpair(imgBold,imgBsRt,'ColorChannels','red-cyan'), axis image;
title('Color composite of affine and s-R-t transform outputs');

% mt=pointsAm.Location(:,1)-pointsBm.Location(:,1);%ベクトル用
% tt=atan(mt./mmm)%2点の角度計算
mmm=pointsAm.Location(:,2)-pointsBm.Location(:,2);
mmm1=rmoutliers(mmm);
f=527.8;%pix
u=atan(mmm/f);
u1=atan(mmm1/f);

uu=mean(rad2deg(u))

uu1=mean(rad2deg(u1))