clear all;clc;close all
st=1e-3;
umax=10*rand;
Kp=5*rand; % setto dei valori random
Ki=5*rand; % setto dei valori random
Kaw = Ki/Kp;
%filtro passa basso
Tf=1/10000000;
%filtro notch
wn = 656; %rad/s
xci_z=0.09;
xci_p=1;

ctrl=PI_FN_FBP(st,Kp,Ki,Kaw,wn,xci_z,xci_p,Tf);
ctrl.SetUmax(umax);

%% TEST CLOSE LOOP
s = tf('s');
ctrl_continuo = (Kp+Ki/s);

%filtro passa basso
Fpbs = tf(1,[Tf 1]);
Fpbz = c2d(Fpbs,st,'tustin');

%filtro notch
Fns = (s^2+2*xci_z*wn*s+wn^2)/(s^2+2*xci_p*wn*s+wn^2);
Fnz = c2d(Fns,st,'tustin');

%controllore - filtro notch - filtro passa basso
ctrl_discreto = c2d(ctrl_continuo,st)*Fnz*Fpbz;
ctrl_continuo=ctrl_continuo*Fns*Fpbs;

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
noise2 = 0.01*sin(100*time);

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
    y_close_loop_class(idx,1)=C*x_processo+noise(idx,1)+noise2(idx,1);
    %y_close_loop_class(idx,1)=C*x_processo;
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
