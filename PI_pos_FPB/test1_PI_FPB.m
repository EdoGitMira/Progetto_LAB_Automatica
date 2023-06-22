clear all;clc;close all
addpath('C:\Users\edoar\Documenti\git hub\Progetto_LAB_Automatica\PI_posizione')
% questo script testa le funzioni della classe

%% TEST starting conditions
for itest=1:100
    st=1e-3;
    Tf=1000;
    Kp=5*rand; % setto dei valori random
    Ki=5*rand; % setto dei valori random
    umax=10*rand;

    ctrl=PIController_pos_FPB(st,Kp,Ki,Tf);
    ctrl.SetUmax(umax);

    ctrl.initialize; % inizializzo

    setpoint=randn;
    y=randn;

    uinitial=rand*umax;
    ctrl.starting(setpoint,y,uinitial); % inizializzo lo stato

    u=ctrl.computeControlAction(setpoint,y);
%     u=ctrl.val_U_pi;
    % the first u should be equal to uinitial
    %disp(itest)
    disp(abs(u-uinitial))


    assert(abs(u-uinitial)<1e-6)
end

%% TEST 2

%% TEST computeControlAction
for itest=1:100
    st=1e-3;
    Kp=5*rand; % setto dei valori random
    Ki=5*rand; % setto dei valori random
    umax=10*rand;
     Tf=1000;
    ctrl=PIController_pos_FPB(st,Kp,Ki,Tf);
    ctrl.SetUmax(umax);
    setpoint=randn;
    ctrl.initialize; % inizializzo


    setpoint=randn;
    y=randn;

    uinitial=rand*umax;
    ctrl.starting(setpoint,y,uinitial); % inizializzo lo stato

    for istep=1:10000
        setpoint=randn;
        y=randn;
        u=ctrl.computeControlAction(setpoint,y);
        % check if u is limited
        assert((u<=umax) && (u>=-umax));
    end
end

