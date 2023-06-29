function [t1,t2,t3]=computeTrapeziodalMotionProfile(ds,max_vel,max_acc)
ds=abs(ds);
acc_time=max_vel/max_acc;
max_triangular_ds=2* (0.5*max_acc*acc_time^2);

if (max_triangular_ds>ds)
    t1=sqrt(ds/max_acc);
    t2=0;
    t3=t1;
else
    ds_t2=ds-max_triangular_ds;
    t1=acc_time;
    t2=ds_t2/max_vel;
    t3=t1;
end


