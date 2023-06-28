clear all;clc;close all
% COMPARE WITH TRANSFER FUNCTION - OPEN LOOP

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
    
    time_test2=(0:st:30)';

    % randn genera un segnale bianco (media nulla)
    % integrale di randn genera un random walk
    % (https://it.wikipedia.org/wiki/Passeggiata_aleatoria)
    reference=cumtrapz(time_test2,randn(length(time_test2),1));
    y=zeros(length(time_test2),1);
    error = reference-y;

    s = tf('s');
    ctrl_continuo = (Kp+Ki/s);

    %filtro passa basso
    Fpbs = tf(1,[Tf 1]);
    Fpbz = c2d(Fpbs,st,'tustin');



    %controllore - filtro notch - filtro passa basso
    ctrl_discreto = c2d(ctrl_continuo,st)*Fpbz;
    
    u_matlab_discrete=lsim(ctrl_discreto,error,time_test2);

    u_class=nan(length(time_test2),1);
    
    for idx=1:length(time_test2)
        u_class(idx,1) = ctrl.computeControlAction(reference(idx),y(idx));
    end

    % check if control action is the same until saturation;
    idx_saturation = find(abs(u_class)>=umax,1)-1;

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

    disp(norm(u_class(1:idx_saturation)-u_matlab_discrete(1:idx_saturation)))
    assert(norm(u_class(1:idx_saturation)-u_matlab_discrete(1:idx_saturation))<1e-6);
end

