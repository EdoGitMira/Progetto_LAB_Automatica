clear all
close all
clc
s = tf('s');


%% define saturazione dei giunti
Umax1 = 200;
Umax2 = 200;
%% define parametri controlli
Kp1 = 0; %P loop esterno giunto 1

Kp2 = 0; %P loop interno giunto 1 
Ki2 = 0; %I loop interno giunto 1 

Kp3 = 0; %P loop esterno giunto 2 

Kp4 = 0; %P loop interno giunto 2 
Ki4 = 0; %P loop esterno giunto 2 

%% define dei parametri del filtro notch 1
wn1 = 223;
xci1_z=0.1; 
xci1_p=0.7;
notch1=(s^2+2*xci1_z*wn1*s+wn1^2)/(s^2+2*xci1_p*wn1*s+wn1^2) 
[num1_fn,den1_fn] = tfdata(notch1);
num1_fn = cell2mat(num1_fn);
den1_fn = cell2mat(den1_fn);

%% define dei parametri del filtro notch 2
wn2 = 223;
xci2_z=0.1; 
xci2_p=0.7;
notch2=(s^2+2*xci2_z*wn2*s+wn2^2)/(s^2+2*xci2_p*wn2*s+wn2^2);
[num2_fn,den2_fn] = tfdata(notch2);
num2_fn = cell2mat(num2_fn);
den2_fn = cell2mat(den2_fn);


%% define dei filtri giunto1
%filtro retrazione di posizione
Fp1 = 1/((1/100000000)*s+1);
[num1_fp,den1_fp] = tfdata(Fp1);
num1_fp = cell2mat(num1_fp);
den1_fp = cell2mat(den1_fp);

%filtro retrazione di velocità
Fv1 = 1/((1/100000000)*s+1);
[num1_fv,den1_fv] = tfdata(Fv1);
num1_fv = cell2mat(num1_fv);
den1_fv = cell2mat(den1_fv);


%% define dei filtri giunto2
%filtro retrazione di posizione
Fp2 = 1/((1/100000000)*s+1);
[num2_fp,den2_fp] = tfdata(Fp2);
num2_fp = cell2mat(num2_fp);
den2_fp = cell2mat(den2_fp);

%filtro retrazione di velocità
Fv2 = 1/((1/100000000)*s+1);
[num2_fv,den2_fv] = tfdata(Fv2);
num2_fv = cell2mat(num2_fv);
den2_fv = cell2mat(den2_fv);