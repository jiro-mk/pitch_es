%% densoten
W=1280;
H=720;
w=5.3;
h=4;
th=110;
tv=70;
fx=527.8;
fy=531.3;


Fx=fx*w/W

Th=rad2deg(2*atan(w/(2*Fx)))
Th1=deg2rad(Th);
w = tan(Th1/2)*2*Fx
%% DR9100 
W=640;%イメージサイズ（横）
H=400;%イメージサイズ（縦）
w=3.6;%センササイズ（横）
h=2.7;%センササイズ（縦）
th=117;%画角（水平）
tv=84;%画角（垂直）
fx=370.8593;%calibrationの結果
fy=365.3433;

Fx_original=1.93;%設計値



Fx=fx*w/W
Fy=fy*h/H


Th=rad2deg(2*atan(w/(2*Fx)))

%% DR3031  
W=640;%イメージサイズ（横）
H=400;%イメージサイズ（縦）
w=3.6;%センササイズ（横）
h=2.7;%センササイズ（縦）
th=107;%画角（水平）
tv=79;%画角（垂直）
fx=338.3778;%calibrationの結果
fy=338.4468;

Fx_original=1.94;%設計値



Fx=fx*w/W
Fy=fy*h/H


Th=rad2deg(2*atan(w/(2*Fx)))

%% DR6200  現物なし（fx,fyは不明）（DR3010と設計値一緒）
W=640;%イメージサイズ（横）
H=400;%イメージサイズ（縦）
w=3.6;%センササイズ（横）
h=2.7;%センササイズ（縦）
th=112;%画角（水平）
tv=82;%画角（垂直）


Fx_original=1.94;%設計値


fx=Fx_original*W/w%calibrationの結果
fy=fy



Th=rad2deg(2*atan(w/(2*Fx)))
%% DRT7300  
W=640;%イメージサイズ（横）
H=400;%イメージサイズ（縦）
w=3.6;%センササイズ（横）
h=2.7;%センササイズ（縦）
th=117;%画角（水平）
tv=84;%画角（垂直）
fx=377.6422;%calibrationの結果
fy=372.9235;

Fx_original=1.93;%設計値



Fx=fx*w/W
Fy=fy*h/H


Th=rad2deg(2*atan(w/(2*Fx)))
