clear all;clc;close all

st=1e-3;
Kp=10; % valori taratura
Ki=2; % valori taratura
umax=150;
Tf=1/200;
ctrl=PIController_pos_FPB(st,Kp,Ki,Tf);
ctrl.setUMax(umax);

% TEST CLOSE LOOP
s=tf('s');

ctrl_continuo=Kp+(Ki/s);
Ti=Kp/Ki;
k1=Kp*(1+(st/Ti));
k2=-Kp;
Fpb = tf(1,[Tf 1]);
z=tf('z',st);   
c=(k1+k2*(z^-1))/(1-z^-1);
ctrl_discreto= c+c2d(Fpb,st,'tustin');

P_continuo=1/(s+1); % modello identificato

P_discreto=c2d(P_continuo,st);
[A,B,C,D]=ssdata(P_discreto);

Y_over_R_discreto=feedback(P_discreto*ctrl_discreto,1);
U_over_R_discreto=feedback(ctrl_discreto,P_discreto);

Y_over_R_continuo=feedback(P_continuo*ctrl_continuo,1);
U_over_R_continuo=feedback(ctrl_continuo,P_continuo);

time=(0:st:10)';
reference=time>1; % step
noise=0.1*sin(2*pi*50*time);
y_close_loop_matlab_discreto=lsim(Y_over_R_discreto,reference,time);
u_close_loop_matlab_discreto=lsim(U_over_R_discreto,reference,time);

y_close_loop_matlab_continuo=lsim(Y_over_R_continuo,reference,time);
u_close_loop_matlab_continuo=lsim(U_over_R_continuo,reference,time);


x_processo=zeros(order(P_discreto),1);
ctrl.initialize;

y_close_loop_class=nan(length(time),1);
u_close_loop_class=nan(length(time),1);
for idx=1:length(time)
    y_close_loop_class(idx,1)=C*x_processo+noise(idx);
    u_close_loop_class(idx,1)=ctrl.computeControlAction(reference(idx),y_close_loop_class(idx,1));
    x_processo=A*x_processo+B*u_close_loop_class(idx,1);
end


figure(3)
set(gcf,'color','w');
subplot(2,1,1)
stairs(time,y_close_loop_class,'LineWidth',0.5,'Color',"#EDB120")
hold on
stairs(time,y_close_loop_matlab_discreto,'LineWidth',1.2,'Color',"#0072BD")

stairs(time,y_close_loop_matlab_continuo,'LineWidth',1.2,'Color',	"#D95319")

hold off
grid on
xlabel('time[s]', 'fontweight', 'bold')
ylabel('process output', 'fontweight', 'bold')
legend('class','matlab discreto','matlab continuo','Location','best')

subplot(2,1,2)
stairs(time,u_close_loop_class,'LineWidth',0.5,'Color',"#EDB120")
hold on
stairs(time,u_close_loop_matlab_discreto,'LineWidth',1.2,'Color',"#0072BD")

stairs(time,u_close_loop_matlab_continuo,'LineWidth',1.2,'Color',	"#D95319")

hold off
grid on
xlabel('time[s]', 'fontweight', 'bold')
ylabel('control action', 'fontweight', 'bold')
legend('class','matlab discreto','matlab continuo','Location','best')

drawnow
