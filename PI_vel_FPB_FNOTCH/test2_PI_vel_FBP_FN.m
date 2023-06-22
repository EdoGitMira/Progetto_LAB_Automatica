clear all;clc;close all
% COMPARE WITH TRANSFER FUNCTION - OPEN LOOP
addpath('C:\Users\edoar\Documenti\git hub\Progetto_LAB_Automatica\PI_vel_FPB_FNOTCH\')

for itest=1:100
    disp(itest)
    st=1e-3;
    Kp = 5*rand; % setto dei valori random
    umax=10*rand;

    Tf = 1/2000;
   
    wn = 656; %rad/s
    xci_z=0.09; 
    xci_p=1; 

    ctrl=PI_vel_FBP_FN(st,Kp,Tf,wn,xci_z,xci_p);
    ctrl.SetUmax(umax);
    ctrl.initialize;
    
    time_test2=(0:st:30)';

    % randn genera un segnale bianco (media nulla)
    % integrale di randn genera un random walk
    % (https://it.wikipedia.org/wiki/Passeggiata_aleatoria)
    reference=cumtrapz(time_test2,randn(length(time_test2),1));
    y=zeros(length(time_test2),1);
    e=reference-y;

    s=tf('s');
    ctrl_continuo=tf(Kp);

    Fs = tf(1,[Tf 1]);
    Fz = c2d(Fs,st,'tustin');

    Fsn = (s^2+2*xci_z*wn*s+wn^2)/(s^2+2*xci_p*wn*s+wn^2);
    Fzn = c2d(Fsn,st,'tustin');

    ctrl_discreto=c2d(ctrl_continuo,st)*Fz*Fzn;
    ctrl_continuo=Kp*Fs*Fsn;

    u_matlab_discrete=lsim(ctrl_discreto,e,time_test2);

    u_class=nan(length(time_test2),1);

    ctrl.starting(reference(1),y(1),0);
    for idx=1:length(time_test2)
        u_class(idx,1)=ctrl.computeControlAction(reference(idx),y(idx));
    end

    % check if control action is the same until saturation;
    idx_saturation=find(abs(u_class)>=umax,1)-1;
    figure(1)
    subplot(2,1,1)
    plot(time_test2,u_class,time_test2,u_matlab_discrete)
    grid on
    hold on
    plot(time_test2,+umax*ones(length(time_test2),1),'--k')
    plot(time_test2,-umax*ones(length(time_test2),1),'--k')
    hold off

    xlabel('time')
    ylabel('control action')
    legend('class','transfer function')

    subplot(2,1,2)
    plot(time_test2,u_class-u_matlab_discrete)
    grid on
    xlabel('time')
    ylabel('diff. control action')
    drawnow
    %disp(norm(u_class(1:idx_saturation)-u_matlab_discrete(1:idx_saturation)))
    assert(norm(u_class(1:idx_saturation)-u_matlab_discrete(1:idx_saturation))<1e-6);

end

