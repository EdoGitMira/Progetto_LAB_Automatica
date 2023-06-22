clear all;clc;close all
addpath('C:\Users\edoar\Documenti\git hub\Progetto_LAB_Automatica\PI_vel_FPB_FNOTCH\')
% questo script testa le funzioni della classe

%% TEST starting conditions
for itest=1:100
    st=1e-3;
    Kp=5*rand; % setto dei valori random
    Tf=1/1000;
    umax=10*rand;
    wn = 656; %rad/s
    xci_z=0.09; 
    xci_p=1; 
    ctrl=PI_vel_FBP_FN(st,Kp,Tf,wn,xci_z,xci_p);
    ctrl.setUMax(umax);
    ctrl.initialize;
    

    %y = k*(setpoint-y(t-1))

    setpoint=randn;
    y=randn;
    uinitial=(setpoint-y)*Kp;
    ctrl.starting(setpoint,y,uinitial);
    u=ctrl.computeControlAction(setpoint,y);
    % the first u should be equal to uinitial
    disp(itest)
    disp(abs(u-uinitial))
    assert(abs(u-uinitial)<1e-6)
end

%% TEST 2

%% TEST computeControlAction
for itest=1:100
    st=1e-3;
    Kp=5*rand; % setto dei valori random
    Ki=5*rand; % setto dei valori random
    Tf=1/(1000*rand);
    umax=10*rand;
    wn = 656; %rad/s
    xci_z=0.09; 
    xci_p=1; 

    ctrl=PI_vel_FBP_FN(st,Kp,Tf,wn,xci_z,xci_p);
    ctrl.SetUmax(umax);

    ctrl.initialize; % inizializzo
    uinitial=rand*umax;
    

    for istep=1:10000
        setpoint=randn;
        y=randn;
        u=ctrl.computeControlAction(setpoint,y);
        % check if u is limited
        assert((u<=umax) && (u>=-umax));
    end
    disp(itest)
end

