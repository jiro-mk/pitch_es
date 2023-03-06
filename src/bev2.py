import cv2
import numpy as np

# カメラの内部パラメータを設定する
K = np.array([[fx, 0, cx], [0, fy, cy], [0, 0, 1]])
dist_coef = np.array([k1, k2, p1, p2, k3])

# カメラ画像を読み込む
img = cv2.imread('input.jpg')

# 歪み補正を行う
h, w = img.shape[:2]
newcameramatrix, roi = cv2.getOptimalNewCameraMatrix(K, dist_coef, (w, h), 1, (w, h))
dst = cv2.undistort(img, K, dist_coef, None, newcameramatrix)

# 透視投影を行う
birds_eye_view = cv2.warpPerspective(dst, M, (width, height), flags=cv2.INTER_LINEAR)

# 結果を表示する
cv2.imshow('input', img)
cv2.imshow('output', birds_eye_view)
cv2.waitKey(0)
cv2.destroyAllWindows()


"""
鳥瞰図を作成するためには、透視投影を行う必要があります。透視投影では、投影面と物体との距離や角度によって、物体の形状が変形してしまいます。このため、透視投影を行う前に、歪み補正を行い、画像の歪みを修正する必要があります。

歪み補正を行った後、鳥瞰図を作成するには、以下の手順に従います。

変換前の画像と鳥瞰図の間に、平行な2つの直線を設定します。これらの直線は、鳥瞰図で平行になるように選択する必要があります。
これらの直線の座標を変換前の画像と鳥瞰図の座標に対応付けます。このためには、2つの座標系間の変換行列を求める必要があります。この行列をMとします。
変換行列Mを使用して、変換前の画像を鳥瞰図に変換します。
変換行列Mを求めるためには、cv2.getPerspectiveTransform()関数を使用します。この関数に、変換前の画像と鳥瞰図の座標を与えることで、変換行列Mを求めることができます。以下は、変換前の画像の4つの座標を(x1, y1), (x2, y2), (x3, y3), (x4, y4)、鳥瞰図の4つの座標を(u1, v1), (u2, v2), (u3, v3), (u4, v4)とした場合の、Mを求める例です。
"""

# 変換前の座標と鳥瞰図の座標を設定する
src = np.float32([[x1, y1], [x2, y2], [x3, y3], [x4, y4]])
dst = np.float32([[u1, v1], [u2, v2], [u3, v3], [u4, v4]])

# 変換行列Mを求める
M = cv2.getPerspectiveTransform(src, dst)

"""
"""


import cv2
import numpy as np

# カメラの内部パラメータ
focal_length = 1000
camera_center_x = 320
camera_center_y = 240

# カメラの取り付け角度（単位：度）
tilt_angle = 45.0

# カメラの取り付け高さ
camera_height = 2.0

# 逆透視変換のための射影行列の作成
theta = np.deg2rad(tilt_angle)
R = np.array([[1, 0, 0], [0, np.cos(theta), -np.sin(theta)], [0, np.sin(theta), np.cos(theta)]])
T = np.array([[0], [-camera_height], [0]])
K = np.array([[focal_length, 0, camera_center_x], [0, focal_length, camera_center_y], [0, 0, 1]])
P = K @ R @ np.hstack((np.identity(3), T))

# 入力画像の読み込み
img = cv2.imread('input_image.jpg')

# 逆透視変換による鳥瞰図の生成
bird_view = cv2.warpPerspective(img, P, (640, 480))

# 結果の表示
cv2.imshow('Input Image', img)
cv2.imshow('Bird View', bird_view)
cv2.waitKey()
cv2.destroyAllWindows()
