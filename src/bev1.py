import cv2
import numpy as np

# 1. Load Raw Image
imagepath = "/home/koichi/my_photo-1.jpg"
rawImage = cv2.imread(imagepath, cv2.IMREAD_COLOR)
cv2.namedWindow("Raw Image", cv2.WINDOW_AUTOSIZE)
cv2.imshow("Raw Image", rawImage)

# 2. Undistort Image Based on Calibration Matrix
undistortImage = np.zeros((rawImage.shape[0], rawImage.shape[1], 3), dtype=np.uint8)
K = np.array([[627.235434, 0, 654.957574],
              [0, 630.482585, 494.346943],
              [0, 0, 1]], dtype=np.float64)
D = np.array([-0.210146, 0.030563, 0.001172, -0.001306], dtype=np.float64)
cv2.undistort(rawImage, undistortImage, K, D)
cv2.namedWindow("Undistorted Image", cv2.WINDOW_AUTOSIZE)
# cv2.line(undistortImage, (640, 0), (640, 960), (255, 255, 255), 10)
# cv2.line(undistortImage, (0, 460), (1280, 460), (255, 255, 255), 10)
cv2.imshow("Undistorted Image", undistortImage)

# 3. Convert Image to Gray
grayImage = cv2.cvtColor(undistortImage, cv2.COLOR_RGB2GRAY)
cv2.namedWindow("Gray Image", cv2.WINDOW_AUTOSIZE)
cv2.imshow("Gray Image", grayImage)

# 4. Top View Conversion
topImage = np.zeros((rawImage.shape[0], rawImage.shape[1], 3), dtype=np.uint8)
topImageGray = np.zeros((rawImage.shape[0], rawImage.shape[1]), dtype=np.uint8)
Hvc = 2
Hc = 0.7
Dvc = 1.7
f = 630
fp = f
theta = 30.0 / 180.0 * np.pi
s = np.sin(theta)
c = np.cos(theta)
cx = 640
cy = 480
cxp = 640
cyp = 480

for y in range(topImage.shape[0]):
    for x in range(topImage.shape[1]):
        xOrg = x - cx
        yOrg = - y + cy

        newX = int(fp / Hvc * Hc * xOrg / (f * s - yOrg * c))
        newY = int(fp / Hvc * (Hc * (f * c + yOrg * s) / (f * s - yOrg * c) - Dvc))

        newX = newX + cxp
        newY = -newY + cyp

        if newX < 0 or topImage.shape[1] - 1 < newX or newY < 0 or topImage.shape[0] - 1 < newY:
            continue

        topImageGray[newY, newX] = grayImage[y, x]

        topImage[newY, newX, :] = undistortImage[y, x, :]

cv2.namedWindow("Top Image", cv2.WINDOW_AUTOSIZE)
cv2.imshow("Top Image", topImage)
cv2.namedWindow("Top Image Gray", cv2.WINDOW_AUTOSIZE)
cv2.imshow("Top
