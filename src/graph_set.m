% �t�H���g�ݒ�
set(0,'defaultAxesFontSize',20)                    % ���̃t�H���g�T�C�Y�ݒ�
set(0,'defaultAxesFontName','Times New Roman')    % ���̃t�H���g�w��(Times New Roman)
set(0,'defaultTextFontSize',20)                    % �����̃t�H���g�T�C�Y�ݒ�
set(0,'defaultTextFontName','Times New Roman')    % �����̃t�H���g�w��(Times New Roman)
set(0,'defaultLineLineWidth',3)      

t=linspace(0,100001,100001);
plot(t,in1',t,out1')

legend('Real Output','NN Output')
xlabel('Time');
% ylabel('Output');
% 
% yy=out2-out3;
% rmse=rms(yy);