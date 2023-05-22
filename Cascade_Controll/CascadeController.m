classdef CascadeController < BaseController
    %CASCADECONTROLLER implementazione di un controllore a cascate dove
    %viene passato sia la posizione che la velocità nei loop di controllo e
    %si utilizza la coppia come attuazione
    properties
        
        Umax1 %azione di controllo massima per il giunto1
        Umax2 %azione di controllo massima per il giunto2
    
        PI1_pos % PI posizione giunto 1
        PI1_vel % PI velocità giunto 1
   
        PI2_pos % PI posizione giunto 2
        PI2_vel % PI velocità giunto 2
        
        F1  %filtro sulla retroazione velocità 1 passa bassa
        F2  %filtro sulla retroazione velocità 2 passa bassa
        %F3  %filtro sulla retroazione posizione 1 passa bassa
        %F4  %filtro sulla retroazione posizione 2 passa bassa
        
        
        Fn1 %filtro notch giunto 1
        Fn2 %filtro notch giunto 2
       
        model % modello utilizzato per la funzione di feedfowward di coppia
    end
    
    methods
        %CASCADECONTROLLER Construct
        function obj = CascadeController(st,...
                Kp1_pos,Ki1_pos,Kp1_vel,Ki1_vel,...
                Kp2_pos,Ki2_pos,Kp2_vel,Ki2_vel,...
                Tf1,Tf2,...
                Wn_notch1,xc_z1,xc_p1,...
                Wn_notch2,xc_z2,xc_p2)
        
            %check dei valori inseriti
            assert(isscalar(st));
            assert(st>0);
            
            assert(isscalar(Kp1_pos));
            assert(Kp1_pos>0);
            assert(isscalar(Ki1_pos));
            assert(Ki1_pos>0);
            
            assert(isscalar(Kp2_pos));
            assert(Kp2_pos>0);
            assert(isscalar(Ki2_pos));
            assert(Ki2_pos>0);
            
            assert(isscalar(Kp1_vel));
            assert(Kp1_vel>0);
            assert(isscalar(Ki1_vel));
            assert(Ki1_vel>0);
            
            assert(isscalar(Kp2_vel));
            assert(Kp2_vel>0);
            assert(isscalar(Ki2_vel));
            assert(Ki2_vel>0);
            
            assert(isscalar(Tf1));
            assert(Tf1>0);
            assert(isscalar(Tf2));
            assert(Tf2>0);          
%             assert(isscalar(Tf3));
%             assert(Tf3>0);
%             assert(isscalar(Tf4));
%             assert(Tf4>0);          

            assert(isscalar(Wn_notch1));
            assert(Wn_notch1>0);
            assert(isscalar(xc_z1));
            assert(xc_z1>0);
            assert(isscalar(xc_p1));
            assert(xc_p1>0);
            
            assert(isscalar(Wn_notch2));
            assert(Wn_notch2>0);
            assert(isscalar(xc_z2));
            assert(xc_z2>0);
            assert(isscalar(xc_p2));
            assert(xc_p2>0);
            
            %setting dei parametri dei controllori
            obj@BaseController(st);
            obj.PI1_pos = PIController_pos(st,Kp1_pos,Ki1_pos);
            obj.PI2_pos = PIController_pos(st,Kp2_pos,Ki2_pos);
            
            obj.PI1_vel = PIController_vel(st,Kp1_vel);
            obj.PI2_vel = PIController_vel(st,Kp2_vel);
            
            %setting dei filtri del primo ordine per i sensori
            obj.F1 = FilterFirstOrder(Tf1,st);%velocità 1
            obj.F2 = FilterFirstOrder(Tf2,st);%velocità 2
            %obj.F3 = FilterFirstOrder(Tf3,st);%posizione 1
            %obj.F4 = FilterFirstOrder(Tf4,st);%posizione 2
            
            %setting dei filtri notch dei due giunti
            obj.Fn1 = FilterNotch(Wn_notch1,xc_z1,xc_p1,st);
            obj.Fn2 = FilterNotch(Wn_notch2,xc_z2,xc_p2,st);
            
            
        end
        
        function obj=initialize(obj)

        end
        
        % setta l'azione di controllo massima nei due controlli PI di
        % velocità che sono quelli che pilotano direttamente il motore
        function setUMax(obj,umax)

        end
        
        function obj=starting(obj,reference,y,u)

        end

        function u=computeControlAction(obj,reference,y)
            %valori letti dai sensori per le azionei di feedback
            J1_pos = y(1);
            J2_pos = y(2);
            
            J1_vel = y(3);
            J2_vel = y(4);
            
            %riferimento di posizione e velocità
            setpoint_J1_pos = reference(1);
            setpoint_J2_pos = reference(2);
            setpoint_J1_vel = reference(3);
            setpoint_J2_vel = reference(4);

            %accellerazione per il calcolo dell'azione di feedfoward
            % setpoint_J2_acc=reference(5);
            % setpoint_J2_acc=reference(6);
            
            % calcolo della coppia da applicare nell'azione feedforward
%             Torque_FF=obj.model.inverseDynamics([sp_pos_jnt1;sp_pos_jnt2],...
%                                                 [sp_vel_jnt1;sp_vel_jnt2],...
%                                                 [sp_acc_jnt1;sp_acc_jnt2]);
%           
            Torque_FF(1) = 0;
            Torque_FF(2) = 0;
            
            Vel1 = obj.PI1_pos.computeControlAction(setpoint_J1_pos,J1_pos);
            Torque1 = obj.PI1_vel.computeControlAction(Vel1,J1_vel,Torque_FF(1));
            
            Vel2 = obj.PI1_pos.computeControlAction(setpoint_J2_pos,J2_pos);
            Torque2 = obj.PI2_vel.computeControlAction(Vel2,J2_vel,Torque_FF(2));
            
            % azione di controllo giunto 1
            u(1,1)=Torque1;
            % azione di controllo giunto 2
            u(2,1)=Torque2;
        end
    end
end

