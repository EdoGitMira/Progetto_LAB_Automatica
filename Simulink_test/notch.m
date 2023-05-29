function y = notch(t,u)
    persistent ym1  um1
    if t<0.001 %
        ym1=0.;
        um1=-0.01;
        y=0.;
    else
        u_now = ym1+Kp*((1+(Ki*0.001))*u-um1);
        um1 = u;
        ym1 = u_now;
        y = u_now;

    end
end



