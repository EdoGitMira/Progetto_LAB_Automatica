classdef CascadeController < BaseController
    %CASCADECONTROLLER implementazione di un controllore a cascata dove
    %viene passato sia la posizione che la velocità nei loop di controllo e
    %si utilizza la coppia come attuazione

    %un primo tentativo si era ipotizzato di realizzare un P interno e un
    %PI esterno ma per problemi con l'azione di controllore probabilmente
    %legati alla gestione dell' antiwind up si è deciso di implementare il 
    %PI internamente per la più faciel gestione del antiwindup e un
    %controllore P nel loop esterno.
    
    properties
    %--------------controllori per il primo giunto-------------------------
        %PI per loop interno con filtro notch e passa basso
        PI1vel_Fn_Fpb
        %P per il loop esterno con filtro notch 
        P1pos_Fpb

     %--------------controllori per il secondo giunto----------------------
        %PI per loop interno con filtro notch e passa basso
        PI2vel_Fn_Fpb
        %P per il loop esterno con filtro notch 
        P2pos_Fpb

    %--------------modello rigido del robot per azione di feedfoward-------
        model
    end
    
    methods
        %CASCADECONTROLLER Construct
        function obj = CascadeController(st,IdynModel,...
                Kp1_pos,Kp1_vel,Ki1_vel,Kaw1_vel,...
                Kp2_pos,Kp2_vel,Ki2_vel,Kaw2_vel,...
                Wn_notch1,xc_z1,xc_p1,...
                Wn_notch2,xc_z2,xc_p2,...
                Tf1_pos,Tf1_vel,...
                Tf2_pos,Tf2_vel)

        
%-----------check dei valori inseriti--------------------------------------
            assert(isscalar(st));
            assert(st>0);
            %check dei valori inseriti giunto 1
            assert(isscalar(Kp1_pos));
            assert(Kp1_pos>0);
            assert(isscalar(Kp1_vel));
            assert(Kp1_vel>0);
            assert(isscalar(Ki1_vel));
            assert(Ki1_vel>0);
            assert(isscalar(Kaw1_vel));
            assert(Kaw1_vel>0);
            %check dei valori inseriti giunto 2
            assert(isscalar(Kp2_pos));
            assert(Kp2_pos>0);
            assert(isscalar(Kp2_vel));
            assert(Kp2_vel>0);
            assert(isscalar(Ki2_vel));
            assert(Ki2_vel>0);
            assert(isscalar(Kaw2_vel));
            assert(Kaw2_vel>0);
            %check dei valori inseriti filtro notch giunto 1
            assert(isscalar(Wn_notch1));
            assert(Wn_notch1>0);
            assert(isscalar(xc_z1));
            assert(xc_z1>0);
            assert(isscalar(xc_p1));
            assert(xc_p1>0);
            %check dei valori inseriti filtro notch giunto 2
            assert(isscalar(Wn_notch2));
            assert(Wn_notch2>0);
            assert(isscalar(xc_z2));
            assert(xc_z2>0);
            assert(isscalar(xc_p2));
            assert(xc_p2>0);
            %check dei valori inseriti filtro passa basso giunto 1
            assert(isscalar(Tf1_pos));
            assert(Tf1_pos>0);
            assert(isscalar(Tf1_vel));
            assert(Tf1_vel>0);
            %check dei valori inseriti filtro passa basso giunto 2
            assert(isscalar(Tf2_pos));
            assert(Tf2_pos>0);          
            assert(isscalar(Tf2_vel));
            assert(Tf2_vel>0);           
%--------------------------------------------------------------------------
%-----------setting dei parametri dei controllori--------------------------
            obj@BaseController(st);
            obj.P1pos_Fpb=;
            obj.PI1vel_Fn_Fpb=;
            
            obj.P2pos_Fpb=;
            obj.PI2vel_Fn_Fpb=;
            

%-----------setting del modello rigido per FF------------------------------
            obj.model = IdynModel;
        end
        
        %funzione di inizializzazione dei sistemi
        function obj = initialize(obj)
            obj.P1pos_Fpb.initialize;
            obj.PI1vel_Fn_Fpb.initialize;
            obj.P2pos_Fpb.initialize;
            obj.PI2vel_Fn_Fpb.initialize;
        end

        % setta l'azione di controllo massima nei due controlli PI di
        % velocità che sono quelli che pilotano direttamente il motore
        function obj = setUMax(obj,umax1,umax2)
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
            upos12= u2/obj.P2vel_Fpb_Fn.Kp + vel2;

            obj.PI1pos_Fpb.starting(ref1,pos1,upos1);
            obj.PI2pos_Fpb.starting(ref2,pos2,upos2); 
            
            obj.P1vel_Fpb_Fn.starting(upos1,vel1,u1);
            obj.P1vel_Fpb_Fn.starting(upos2,vel2,u2);
        end
                
        function u = computeControlAction(obj,reference,y)
        %------------------------------------------------------------------
        %-----definizione delle varibabili per il controlllo

            %valori letti dai sensori azioni di feedback
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
            Torque1 = obj.P1vel_Fpb_Fn.computeControlAction(Upi_pos1,vel_j1);
            Torque2 = obj.P1vel_Fpb_Fn.computeControlAction(Upi_pos2,vel_j2);     
    
            
            % azione di controllo giunto 1
            u(1,1) = Torque1;
            % azione di controllo giunto 2
            u(2,1) = Torque2;
        end
    end
end

