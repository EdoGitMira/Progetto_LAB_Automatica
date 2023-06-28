clear all;clc;close all
% questo script testa le funzioni della classe

%% TEST starting conditions
for itest=1:100
    st=1e-3;
    umax=10*rand;
    Kp=5*rand; % setto dei valori random
    Ki=5*rand; % setto dei valori random
    Kaw = Ki/Kp;
    %filtro passa basso
    Tf=1/1000;

    ctrl=PI_FBP(st,Kp,Ki,Kaw,Tf);
    ctrl.setUMax(umax);
    ctrl.initialize;
    
    setpoint=randn;
    y=randn;

    uinitial=rand*umax;%aggiungere possibilità di numeri negativi
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
    umax=10*rand;
    Kp=5*rand; % setto dei valori random
    Ki=5*rand; % setto dei valori random
    Kaw = Ki/Kp;
    %filtro passa basso
    Tf=1/1000;


    ctrl=PI_FBP(st,Kp,Ki,Kaw,Tf);
    ctrl.SetUmax(umax);

    ctrl.initialize; % inizializzo
    uinitial=rand*umax;
     ctrl.starting(setpoint,y,uinitial); % inizializzo lo stato
    for istep=1:10000
        setpoint=randn;
        y=randn;
        u=ctrl.computeControlAction(setpoint,y);
        % check if u is limited
        assert((u<=umax) && (u>=-umax));
    end
    disp(itest)
end

