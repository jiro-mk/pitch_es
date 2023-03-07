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




"""

"""

import numpy as np
import cv2

# カメラの内部パラメータ
fx = 700.0
fy = 700.0
cx = 320.0
cy = 240.0

# カメラの取り付け角度
tilt_deg = 30.0
tilt_rad = np.deg2rad(tilt_deg)

# カメラの取り付け高さ
camera_height = 2.0

# 逆透視投影変換行列の計算
H = np.array([
    [fx / np.tan(tilt_rad), 0, cx],
    [0, fy / np.sin(tilt_rad), cy],
    [0, 0, 1]
])
K = np.array([
    [1, 0, 0],
    [0, 1, 0],
    [0, 0, 1 / camera_height]
])
M = K @ H
M_inv = np.linalg.inv(M)

# 入力画像の読み込み
img = cv2.imread('input_image.jpg')

# 逆透視投影変換による鳥瞰図の生成
height, width = img.shape[:2]
birdview_width = 800
birdview_height = 600
birdview_range = ((0, birdview_width), (0, birdview_height))
birdview = cv2.warpPerspective(img, M_inv, (birdview_width, birdview_height))

# 鳥瞰図の表示範囲の設定
birdview_roi = np.array([[100, 500], [200, 400], [600, 400], [700, 500]])
birdview_mask = np.zeros((birdview_height, birdview_width), np.uint8)
cv2.fillPoly(birdview_mask, [birdview_roi], (255, 255, 255))
birdview_mask_inv = cv2.bitwise_not(birdview_mask)
birdview_masked = cv2.bitwise_and(birdview, birdview, mask=birdview_mask)
birdview_cropped = birdview_masked[birdview_roi[1][1]:birdview_roi[0][1], birdview_roi[1][0]:birdview_roi[2][0]]

# 鳥瞰図の描画と保存
cv2.imshow('Birdview', birdview_cropped)
cv2.imwrite('birdview.jpg', birdview_cropped)

# 鳥瞰図のピクセル値から距離の計算
birdview_gray = cv2.cvtColor(birdview_cropped, cv2.COLOR


"""

"""
import cv2
import numpy as np

def get_transform_matrix(image_shape, f, theta, h):
    """
    逆透視投影変換に必要な射影変換行列を返します。
    image_shape: 入力画像の形状 (高さ, 幅)
    f: カメラの焦点距離
    theta: カメラの取り付け角度
    h: カメラの取り付け高さ
    """
    w = image_shape[1]
    # 射影変換行列を計算します。
    M = np.float32([[1, 0, 0],
                    [np.tan(theta), 1, 0],
                    [0, 0, 1]])
    # 逆透視投影変換行列を計算します。
    K = np.float32([[f, 0, w / 2],
                    [0, f, h],
                    [0, 0, 1]])
    return np.dot(K, M)

def inverse_perspective_mapping(img, transform_matrix, output_shape):
    """
    逆透視投影変換を使用して、imgをoutput_shapeの鳥瞰図に変換します。
    """
    # 出力画像の座標系を定義します。
    rows, cols = output_shape[:2]
    x_scale = float(cols) / img.shape[1]
    y_scale = float(rows) / img.shape[0]
    x_offset = cols / 2
    y_offset = rows
    # 逆透視投影変換を適用します。
    map_x, map_y = np.meshgrid(np.arange(cols), np.arange(rows))
    map_x = (map_x - x_offset) / x_scale
    map_y = (map_y - y_offset) / y_scale
    map_xy = np.float32([map_x, map_y, np.ones_like(map_x)])
    transformed_xy = np.dot(transform_matrix, map_xy)
    transformed_xy /= transformed_xy[2]
    transformed_x, transformed_y = transformed_xy[:2]
    transformed_x = transformed_x.astype(np.float32)
    transformed_y = transformed_y.astype(np.float32)
    # 変換された座標が範囲内にあるピクセルの値を取得します。
    output = cv2.remap(img, transformed_x, transformed_y, cv2.INTER_LINEAR)
    return output

def pixel_to_distance(pixel_value, f, height):
    """
    ピクセル値を距離に変換します。
    pixel_value: 変換したいピクセル値
    f: カメラの焦点距離
    height: カメラの高さ
    """
    return f * height / pixel_value

# パラメータを設定します。
focal_length = 500  #
