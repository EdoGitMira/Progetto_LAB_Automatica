function cost=pivel_cost_function(x,P,wc_des)
% J =(wc-wc_des)^2 = (wc_des-wc)^2
% L=P*C ha modulo pari a 1 (o 0 dB)

% C=(Kp*s+Ki)/s;
Kp=x(1);
Ki=x(2);
C=tf([Kp Ki],[1 0]);

L=P*C;
margini=allmargin(L);



if isempty(margini.PMFrequency)
    cost=100;
else
    cost=(wc_des-margini.PMFrequency(end))^2;
end