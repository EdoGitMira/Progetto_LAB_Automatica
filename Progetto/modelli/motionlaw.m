function [t,q,qd,qdd]=motionlaw(waypoints,max_vel,max_acc,dt,rest_time)
if nargin<5
    rest_time=0;
end
nax=size(waypoints,1);

Ttot=0;

for iw=1:size(waypoints,2)-1

    Tseg(iw)=0;t1(iw)=0;t2(iw)=0;t3(iw)=0;

    for iax=1:nax
        ds=waypoints(iax,iw+1)-waypoints(iax,iw);
        [t1_ax,t2_ax,t3_ax]=computeTrapeziodalMotionProfile(ds,max_vel,max_acc);
        Ttot_ax=t1_ax+t2_ax+t3_ax;
        if (Ttot_ax>Tseg(iw))
            Tseg(iw)=Ttot_ax;
            t1(iw)=t1_ax;
            t2(iw)=t2_ax;
            t3(iw)=t3_ax;
        end
    end
    Ttot=Ttot+Tseg(iw);
end
Ttot=Ttot+rest_time;
t=(0:dt:Ttot);
q=repmat(waypoints(:,1),1,length(t));%zeros(nax,length(t));
qd=zeros(nax,length(t));
qdd=zeros(nax,length(t));


t0=0;
for iw=1:size(waypoints,2)-1

    idxs=find(t>t0);
    for iax=1:nax

        ds=waypoints(iax,iw+1)-waypoints(iax,iw);
        q0=waypoints(iax,iw);
        [y,yd,ydd]=evalTrapeziodalMotion(t0,q0,t1(iw),t2(iw),t3(iw),ds,t(idxs));

        q(iax,idxs)=y;
        qd(iax,idxs)=yd;
        qdd(iax,idxs)=ydd;
    end
    t0=t0+Tseg(iw);
end