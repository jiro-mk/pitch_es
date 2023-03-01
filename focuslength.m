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
W=640;%�C���[�W�T�C�Y�i���j
H=400;%�C���[�W�T�C�Y�i�c�j
w=3.6;%�Z���T�T�C�Y�i���j
h=2.7;%�Z���T�T�C�Y�i�c�j
th=117;%��p�i�����j
tv=84;%��p�i�����j
fx=370.8593;%calibration�̌���
fy=365.3433;

Fx_original=1.93;%�݌v�l



Fx=fx*w/W
Fy=fy*h/H


Th=rad2deg(2*atan(w/(2*Fx)))

%% DR3031  
W=640;%�C���[�W�T�C�Y�i���j
H=400;%�C���[�W�T�C�Y�i�c�j
w=3.6;%�Z���T�T�C�Y�i���j
h=2.7;%�Z���T�T�C�Y�i�c�j
th=107;%��p�i�����j
tv=79;%��p�i�����j
fx=338.3778;%calibration�̌���
fy=338.4468;

Fx_original=1.94;%�݌v�l



Fx=fx*w/W
Fy=fy*h/H


Th=rad2deg(2*atan(w/(2*Fx)))

%% DR6200  �����Ȃ��ifx,fy�͕s���j�iDR3010�Ɛ݌v�l�ꏏ�j
W=640;%�C���[�W�T�C�Y�i���j
H=400;%�C���[�W�T�C�Y�i�c�j
w=3.6;%�Z���T�T�C�Y�i���j
h=2.7;%�Z���T�T�C�Y�i�c�j
th=112;%��p�i�����j
tv=82;%��p�i�����j


Fx_original=1.94;%�݌v�l


fx=Fx_original*W/w%calibration�̌���
fy=fy



Th=rad2deg(2*atan(w/(2*Fx)))
%% DRT7300  
W=640;%�C���[�W�T�C�Y�i���j
H=400;%�C���[�W�T�C�Y�i�c�j
w=3.6;%�Z���T�T�C�Y�i���j
h=2.7;%�Z���T�T�C�Y�i�c�j
th=117;%��p�i�����j
tv=84;%��p�i�����j
fx=377.6422;%calibration�̌���
fy=372.9235;

Fx_original=1.93;%�݌v�l



Fx=fx*w/W
Fy=fy*h/H


Th=rad2deg(2*atan(w/(2*Fx)))
