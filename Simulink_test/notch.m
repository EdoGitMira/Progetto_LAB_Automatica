function y = notch(t,u)
    persistent y_1 y_2 u_1 u_2
    if t<0.001 %
        y_1=0;
        y_2=0;
        u_1=0;
        u_2=0;
        y=u-1.917*u_1+0.959*u_2+1.689*y_1-0.7318*y_2;
        u_2=u_1;
        u_1 = u;
        y_2=y_1;
        y_1 = y;
    else
        y = u-1.917*u_1+0.959*u_2+1.689*y_1-0.7318*y_2;
        u_2=u_1;
        u_1 = u;
        
        y_2=y_1;
        y_1 = y;

    end
end



