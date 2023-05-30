function y = passa_basso(t,u)
    persistent y_1  u_1 
    if t<0.001 %
        y_1=0;
        
        u_1=0;
         y = 0.5507*u_1+0.4493*y_1;
        u_1 = u;
        y_1 = y;
    else
        y = 0.5507*u_1+0.4493*y_1;
        u_1 = u;
        y_1 = y;

    end
end



