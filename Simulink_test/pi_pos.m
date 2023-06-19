    function y = pi_pos(t,u)
        Kp = 1;
        Ki = 10;
        persistent ym1  um1
        if t<0.001 %
            ym1=0.;
            um1=0;
            y_now = ym1+Kp*((1+(Ki*0.001))*u-um1);
            y = y_now;
            um1 = u;
            ym1 = y_now;
        else
            y_now = ym1+Kp*((1+(Ki*0.001))*u-um1);
            um1 = u;
            ym1 = y_now;
            y = y_now;
    
        end
    end

