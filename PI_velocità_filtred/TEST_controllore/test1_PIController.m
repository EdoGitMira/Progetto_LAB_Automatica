clear all;clc;close all
addpath('C:\Users\edoar\Documenti\git hub\Progetto_LAB_Automatica\PI_velocità')
% questo script testa le funzioni della classe

%% TEST starting conditions
for itest=1:100
    st=1e-3;
    Kp=5*rand; % setto dei valori random
    Ki=0; % setto dei valori random
    umax=10*rand;

    ctrl=PIController_vel(st,Kp);
    ctrl.setUMax(umax);

    %y = k*(setpoint-y(t-1))

    setpoint=randn;
    y=randn;
    uinitial=(setpoint-y)*Kp;

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
    umax=10*rand;

    ctrl=PIController_vel(st,Kp);
    ctrl.SetUmax(umax);

    ctrl.initialize; % inizializzo


    uinitial=rand*umax;
    ctrl.starting(); % inizializzo lo stato

    for istep=1:10000
        setpoint=randn;
        y=randn;
        u=ctrl.computeControlAction(setpoint,y);
        % check if u is limited
        assert((u<=umax) && (u>=-umax));
    end
    disp(itest)
end

