    clear all;clc;close all
    addpath('C:\Users\edoar\Documenti\git hub\Progetto_LAB_Automatica\PI_vel_FPB_FNOTCH\')
    st=1e-3;
    Kp=5*rand; % setto dei valori random
    umax=10*rand;
    Tf = 0.000001;
    wn = 10000000; %rad/s
    xci_z=0.1; 
    xci_p=1; 

    ctrl=PI_vel_FBP_FN(st,Kp,Tf,wn,xci_z,xci_p);
    ctrl.SetUmax(umax);

    %% TEST CLOSE LOOP
    s=tf('s');
    ctrl_continuo=tf(Kp);

    Fs = tf(1,[Tf 1]);
    Fz = c2d(Fs,st,'tustin');

    Fsn = (s^2+2*xci_z*wn*s+wn^2)/(s^2+2*xci_p*wn*s+wn^2);
    Fzn = c2d(Fsn,st,'tustin');

    ctrl_discreto=c2d(ctrl_continuo,st)*Fz*Fzn;
    ctrl_continuo=Kp*Fs*Fsn;

P_continuo=1/(s+1); % modello identificato

P_discreto=c2d(P_continuo,st);
[A,B,C,D]=ssdata(P_discreto);

Y_over_R_discreto=feedback(P_discreto*ctrl_discreto,1);
U_over_R_discreto=feedback(ctrl_discreto,P_discreto);

Y_over_R_continuo=feedback(P_continuo*ctrl_continuo,1);
U_over_R_continuo=feedback(ctrl_continuo,P_continuo);

time=(0:st:60)';
reference=time>2; % step
noise=0.01*randn(length(time),1);

y_close_loop_matlab_discreto=lsim(Y_over_R_discreto,reference,time);
u_close_loop_matlab_discreto=lsim(U_over_R_discreto,reference,time);

y_close_loop_matlab_continuo=lsim(Y_over_R_continuo,reference,time);
u_close_loop_matlab_continuo=lsim(U_over_R_continuo,reference,time);


x_processo=zeros(order(P_discreto),1);
ctrl.initialize;
ctrl.starting(reference(1),0,0);
y_close_loop_class=nan(length(time),1);
u_close_loop_class=nan(length(time),1);
for idx=1:length(time)
    %y_close_loop_class(idx,1)=C*x_processo+noise(idx,1);
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
