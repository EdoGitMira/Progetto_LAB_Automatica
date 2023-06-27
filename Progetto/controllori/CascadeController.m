classdef CascadeController < BaseController
    %CASCADECONTROLLER implementazione di un controllore a cascate dove
    %viene passato sia la posizione che la velocità nei loop di controllo e
    %si utilizza la coppia come attuazione
    
    properties
          
        PI1pos_Fpb % PI posizione giunto 1
        P1vel_Fpb_Fn % P velocità giunto 1

        PI2pos_Fpb % PI posizione giunto 2
        P2vel_Fpb_Fn % P velocità giunto 2
   
        model % modello utilizzato per la funzione di feedfowward di coppia
    end
    
    methods
        %CASCADECONTROLLER Construct
        function obj = CascadeController(st,IdynModel,...
                Kp1_pos,Ki1_pos,Kp1_vel,...
                Kp2_pos,Ki2_pos,Kp2_vel,...
                Wn_notch1,xc_z1,xc_p1,...
                Wn_notch2,xc_z2,xc_p2,...
                Tf1_pos,Tf1_vel,...
                Tf2_pos,Tf2_vel)

        
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
%            assert(isscalar(Ki1_vel));
%            assert(Ki1_vel>0);
            
            assert(isscalar(Kp2_vel));
            assert(Kp2_vel>0);
%            assert(isscalar(Ki2_vel));
%            assert(Ki2_vel>0);
              
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

            assert(isscalar(Tf1_pos));
            assert(Tf1_pos>=0);
            assert(isscalar(Tf2_pos));
            assert(Tf2_pos>=0);          
            assert(isscalar(Tf1_vel));
            assert(Tf1_vel>=0);
            assert(isscalar(Tf2_vel));
            assert(Tf2_vel>=0);

            obj@BaseController(st);
%--------------------------------------------------------------------------
%-----------setting dei parametri dei controllori--------------------------
            obj.PI1pos_Fpb = PI_pos_FPB(st,Kp1_pos,Ki1_pos,Tf1_pos);      
            obj.P1vel_Fpb_Fn = PI_vel_FBP_FN(st,Kp1_vel,Tf1_vel,Wn_notch1,xc_z1,xc_p1);
            
            obj.PI2pos_Fpb = PI_pos_FPB(st,Kp2_pos,Ki2_pos,Tf2_pos);
            obj.P2vel_Fpb_Fn = PI_vel_FBP_FN(st,Kp2_vel,Tf2_vel,Wn_notch2,xc_z2,xc_p2);

            obj.model = IdynModel;
        end
        
        %funzione di inizializzazione dei sistemi
        function obj = initialize(obj)
            obj.PI1pos_Fpb.initialize;
            obj.P1vel_Fpb_Fn.initialize;
            obj.PI2pos_Fpb.initialize;
            obj.P2vel_Fpb_Fn.initialize;
        end

        % setta l'azione di controllo massima nei due controlli PI di
        % velocità che sono quelli che pilotano direttamente il motore
        function obj = setUMax(obj,umax)
            umax1 = umax(1);
            umax2 = umax(2);
            %verifica dei parametri utilizzati
            assert(isscalar(umax1));
            assert(umax1>0);
            assert(isscalar(umax2));
            assert(umax2>0);
            %settaggio azioni di saturazione dei controllori
            obj.PI1pos_Fpb.SetUmax(100000);
            obj.P1vel_Fpb_Fn.SetUmax(umax1);
            obj.PI2pos_Fpb.SetUmax(100000);
            obj.P2vel_Fpb_Fn.SetUmax(umax2);
        end

        %funzione di starting per inizializzazione dei filtri e dei
        %controllori
        function obj = Starting(obj,reference,y,u)
            ref1= reference(1);
            ref2 = reference(2);
            u1 = u(1);
            u2 = u(2);
            pos1 = y(1);
            pos2 = y(2);
            vel1 = y(3);
            vel2 = y(4);  

            assert(isscalar(ref1))
            assert(isscalar(ref2))
            assert(isscalar(u1))
            assert(isscalar(u2))
            assert(isscalar(pos1))
            assert(isscalar(pos2))
            assert(isscalar(vel1))
            assert(isscalar(vel2))
            assert(abs(u1)>obj.P1vel_Fpb_Fn.sat)
            assert(abs(u2)>obj.P2vel_Fpb_Fn.sat)

            upos1 = u1/obj.P1vel_Fpb_Fn.Kp + vel1;
            upos2= u2/obj.P2vel_Fpb_Fn.Kp + vel2;

            obj.PI1pos_Fpb.starting(ref1,pos1,upos1)
            obj.PI2pos_Fpb.starting(ref2,pos2,upos2) 
            
            obj.P1vel_Fpb_Fn.starting(upos1,vel1,u1)
            obj.P1vel_Fpb_Fn.starting(upos2,vel2,u2)
        end
                
        function u = computeControlAction(obj,reference,y)
        %------------------------------------------------------------------
        %-----definizione delle varibabili per il controlllo

            %valori letti dai sensori per le azionei di feedback
            pos_j1 = y(1);
            pos_j2 = y(2);
            vel_j1 = y(3);
            vel_j2 = y(4);        
            %riferimento delle leggi di moto
            Sp_pos_j1 = reference(1);
            Sp_pos_j2 = reference(2);
            Sp_vel_j1 = reference(3);
            Sp_vel_j2 = reference(4);
            Sp_acc_j1 = reference(5);
            Sp_acc_j2 = reference(6);

        %------------------------------------------------------------------
        %calcolo azione di controllo del loop esterno 
            Upi_pos1 = obj.PI1pos_Fpb.computeControlAction(Sp_pos_j1,pos_j1);
            Upi_pos2 = obj.PI2pos_Fpb.computeControlAction(Sp_pos_j2,pos_j2);

        %------------------------------------------------------------------
        %calcolo azione  di feedfoward
            T_ff = idynRigid(Sp_pos_j1,Sp_pos_j2,Upi_pos1,Upi_pos2,Sp_acc_j1,Sp_acc_j2,0);

        %------------------------------------------------------------------
        %calcolo azione di controllo del loop interno
        %con feedforward di coppia
            Torque1 = obj.P1vel_Fpb_Fn.computeControlAction(Upi_pos1,vel_j1)+T_ff(1);
            Torque2 = obj.P1vel_Fpb_Fn.computeControlAction(Upi_pos2,vel_j2)+T_ff(2);     
    
            
            % azione di controllo giunto 1
            u(1,1) = Torque1;
            % azione di controllo giunto 2
            u(2,1) = Torque2;
        end
    end
end

