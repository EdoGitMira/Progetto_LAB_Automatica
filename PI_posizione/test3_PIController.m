clear all;clc;close all
addpath('C:\Users\edoar\Documenti\git hub\Progetto_LAB_Automatica\PI_posizione')
for itest=1:100
    st=1e-3;
    Kp=5*rand; % setto dei valori random
    Ki=5*rand; % setto dei valori random
    umax=10*rand;

    ctrl=PIController_pos(st,Kp,Ki);
    ctrl.setUMax(umax);


    %% TEST CLOSE LOOP
     s=tf('s');
    ctrl_continuo=Kp+(Ki/s);
    Ti=Kp/Ki;
    k1=Kp*(1+(st/Ti));
    k2=-Kp;
    z=tf('z',st);   
    c=(k1+k2*(z^-1))/(1-z^-1);
    ctrl_discreto= c;
    
    P_continuo=rss(4); % genero sistema random

    % considero solo sistemi strettamente proprio
    numero_poli=length(pole(P_continuo));
    numero_zeri=length(zero(P_continuo));

    ordine_relativo=numero_poli-numero_zeri;

    if (ordine_relativo==0) % non strettamente proprio, aggiungo un polo
        P_continuo=P_continuo/s;
    end

    
    P_discreto=c2d(P_continuo,st);
    [A,B,C,D]=ssdata(P_discreto);

    Y_over_R_discreto=feedback(P_discreto*ctrl_discreto,1);
    U_over_R_discreto=feedback(ctrl_discreto,P_discreto);

    Y_over_R_continuo=feedback(P_continuo*ctrl_continuo,1);
    U_over_R_continuo=feedback(ctrl_continuo,P_continuo);

    time=(0:st:30)';
    reference=cumtrapz(time,randn(length(time),1));

    y_close_loop_matlab_discreto=lsim(Y_over_R_discreto,reference,time);
    u_close_loop_matlab_discreto=lsim(U_over_R_discreto,reference,time);

    y_close_loop_matlab_continuo=lsim(Y_over_R_continuo,reference,time);
    u_close_loop_matlab_continuo=lsim(U_over_R_continuo,reference,time);


    x_processo=zeros(order(P_discreto),1);
    ctrl.initialize;

    y_close_loop_class=nan(length(time),1);
    u_close_loop_class=nan(length(time),1);
    for idx=1:length(time)
        y_close_loop_class(idx,1)=C*x_processo;
        u_close_loop_class(idx,1)=ctrl.computeControlAction(reference(idx),y_close_loop_class(idx,1));
        x_processo=A*x_processo+B*u_close_loop_class(idx,1);
    end


    figure(3)
    subplot(2,1,1)
    stairs(time,y_close_loop_matlab_discreto)
    hold on
    stairs(time,y_close_loop_matlab_continuo)
    stairs(time,y_close_loop_class)
    hold off
    grid on
    xlabel('time')
    ylabel('process output')
    legend('matlab discreto','matlab continuo','class')

    subplot(2,1,2)
    stairs(time,u_close_loop_matlab_discreto)
    hold on
    stairs(time,u_close_loop_matlab_continuo)
    stairs(time,u_close_loop_class)
    hold off
    grid on
    xlabel('time')
    ylabel('control action')
    legend('matlab discreto','matlab continuo','class')

    drawnow

    % check if control action is the same until saturation;
    idx_saturation=find(abs(u_close_loop_class)>=umax,1)-1;
    assert(norm(y_close_loop_matlab_discreto(1:idx_saturation)-y_close_loop_class(1:idx_saturation))<1e-4)
    assert(norm(u_close_loop_matlab_discreto(1:idx_saturation)-u_close_loop_class(1:idx_saturation))<1e-4)

end