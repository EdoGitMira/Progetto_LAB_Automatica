clear all;clc;close all
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
    
    


    %% TEST CLOSE LOOP
    s = tf('s');
    ctrl_continuo = (Kp+Ki/s);

    %filtro passa basso
    Fpbs = tf(1,[Tf 1]);
    Fpbz = c2d(Fpbs,st,'tustin');


    %controllore - filtro notch - filtro passa basso
    ctrl_discreto = c2d(ctrl_continuo,st)*Fpbz;
    ctrl_continuo=ctrl_continuo*Fpbs;

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
    disp(itest)
    disp(norm(y_close_loop_matlab_discreto(1:idx_saturation)-y_close_loop_class(1:idx_saturation)))
    disp(norm(u_close_loop_matlab_discreto(1:idx_saturation)-u_close_loop_class(1:idx_saturation)))
    assert(norm(y_close_loop_matlab_discreto(1:idx_saturation)-y_close_loop_class(1:idx_saturation))<1e-4)
    assert(norm(u_close_loop_matlab_discreto(1:idx_saturation)-u_close_loop_class(1:idx_saturation))<1e-4)

end