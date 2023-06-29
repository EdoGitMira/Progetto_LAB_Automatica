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
            obj.P1pos_Fpb=P_FPB(st,Kp1_pos,Tf1_pos);
            obj.PI1vel_Fn_Fpb=PI_FN_FBP(st,Kp1_vel,Ki1_vel,Kaw1_vel,Wn_notch1,xc_z1,xc_p1,Tf1_vel);
            
            obj.P2pos_Fpb=P_FPB(st,Kp2_pos,Tf2_pos);
            obj.PI2vel_Fn_Fpb=PI_FN_FBP(st,Kp2_vel,Ki2_vel,Kaw2_vel,Wn_notch2,xc_z2,xc_p2,Tf2_vel);
            
%-----------setting del modello rigido per FF------------------------------
            obj.model = IdynModel;
        end
        
        %metodo di inizializzazione dei controllori richiamo i metodi
        %interni alle classi già implementati
        function obj = initialize(obj)
            obj.P1pos_Fpb.initialize();
            obj.PI1vel_Fn_Fpb.initialize();
            obj.P2pos_Fpb.initialize();
            obj.PI2vel_Fn_Fpb.initialize();
        end

        % metodo per il setting dell'azione di controllo massima nei due 
        % controlli PI di velocità che sono quelli che pilotano 
        % direttamente il motore
        function obj = setUMax(obj,umax)
            %verifica dei parametri utilizzati
            assert(isscalar(umax(1)));
            assert(umax(1)>0);
            assert(isscalar(umax(2)));
            assert(umax(2)>0);

            %settaggio azioni di saturazione dei controllori
            %per il controllore P nei loop estrerni si è scelto di non
            %mettere un limite al valore della azione di controllo che
            %generano però essenso inplementata dentro di essi si mette un
            %valore alto per evitare interferenze

            obj.P1pos_Fpb.SetUmax(100000);
            obj.PI1vel_Fn_Fpb.SetUmax(umax(1));
            
            obj.P2pos_Fpb.SetUmax(100000);
            obj.PI2vel_Fn_Fpb.SetUmax(umax(2));
            
        end

        %metodo di starting per inizializzazione dei filtri e dei
        %controllori
        function obj = Starting(obj)
            
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
            UP1_vel = obj.P1pos_Fpb.computeControlAction(Sp_pos_j1,pos_j1)+Sp_vel_j1;
            UP2_vel = obj.P2pos_Fpb.computeControlAction(Sp_pos_j2,pos_j2)+Sp_vel_j2;

        %------------------------------------------------------------------
        %calcolo azione  di feedfoward
            T_ff = idynRigid(Sp_pos_j1,Sp_pos_j2,UP1_vel,UP2_vel,Sp_acc_j1,Sp_acc_j2,0);

        %------------------------------------------------------------------
        %calcolo azione di controllo del loop interno
        %con feedforward di coppia
            Torque1 = obj.PI1vel_Fn_Fpb.computeControlAction(UP1_vel,vel_j1, 0);
            Torque2 = obj.PI2vel_Fn_Fpb.computeControlAction(UP2_vel,vel_j2, 0);

        %------------------------------------------------------------------
        %Assegnazione dei valori di coppia ai giunti   
            % azione di controllo giunto 1
            u(1,1) = Torque1;
            % azione di controllo giunto 2
            u(2,1) = Torque2;
        end
    end
end

