function [q,qd,qdd]=evalTrapeziodalMotion(t0,q0,t1,t2,t3,ds,t)

%vel=max_acc*t1;
%ds_acc=0.5*max_acc*t1^2;
%ds_vel=vel*t2;
%ds=2*ds_acc+ds_vel;
%ds=max_acc*t1^2+max_acc*t1*t2
%ds=max_acc*(t1^2+t1+t2);
%qf=q0+ds*dir;

dir=sign(ds);
max_acc=abs(ds)/(t1^2+t1*t2);

vel=max_acc*t1;
ds_acc=0.5*max_acc*t1^2;
ds_vel=vel*t2;
%ds=2*ds_acc+ds_vel;
qf=q0+ds;


q=zeros(length(t),1);
qd=zeros(length(t),1);
qdd=zeros(length(t),1);

for idx=1:length(t)
    if t(idx)<t0
        q(idx)=q0;
        qd(idx)=0;
        qdd(idx)=0;
    elseif t(idx)<t0+t1
        dt=t(idx)-t0;
        q(idx)=q0+0.5*max_acc*dir*dt^2;
        qd(idx)=max_acc*dt*dir;
        qdd(idx)=max_acc*dir;
    elseif t(idx)<t0+t1+t2
        dt=t(idx)-t0-t1;
        q(idx)=q0+ds_acc*dir+vel*dt*dir;
        qd(idx)=vel*dir;
        qdd(idx)=0;
    elseif t(idx)<t0+t1+t2+t3
        dt=t(idx)-t0-t1-t2;
        q(idx)=q0+ds_acc*dir+ds_vel*dir+dir*vel*dt-0.5*max_acc*dt^2*dir;
        qd(idx)=vel*dir-max_acc*dt*dir;
        qdd(idx)=-max_acc*dir;
    elseif t(idx)>=t0+t1+t2+t3
        q(idx)=qf;
        qd(idx)=0;
        qdd(idx)=0;
    end            
end