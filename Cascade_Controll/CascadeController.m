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
        function obj = CascadeController(st,...
                Kp1_pos,Ki1_pos,Kp1_vel,...
                Kp2_pos,Ki2_pos,Kp2_vel,...
                Wn_notch1,xc_z1,xc_p1,...
                Wn_notch2,xc_z2,xc_p2,...
                Tf1,Tf2)
                %Tf3,Tf4
        
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

            assert(isscalar(Tf1));
            assert(Tf1>0);
            assert(isscalar(Tf2));
            assert(Tf2>0);          
%            assert(isscalar(Tf3));
%            assert(Tf3>0);
%            assert(isscalar(Tf4));
%            assert(Tf4>0);  

%--------------------------------------------------------------------------
%-----------setting dei parametri dei controllori--------------------------

        end
        
        function obj = initialize(obj)
                       
        end
        
        % setta l'azione di controllo massima nei due controlli PI di
        % velocità che sono quelli che pilotano direttamente il motore
        function obj = setUMax(obj,umax1,umax2)
            obj.Umax1 = umax1;
            obj.Umax2 = umax2;
        end
        
        %funzione di starting per inizializzazione dei filtri e dei
        %controllori
        function obj = Starting(obj,reference,y,u)

        end

        function u = computeControlAction(obj,reference,y)
        %------------------------------------------------------------------
        %-----definizione delle varibabili per il controlllo
        %valori letti dai sensori per le azionei di feedback
            pos_j1 = y(1);
            pos_j2 = y(2);
            vel_j1 = y(3);
            vel_j2 = y(4);        
        %riferimento della legge di moto
            Sp_pos_j1 = reference(1);
            Sp_pos_j2 = reference(2);
            Sp_vel_j1 = reference(3);
            Sp_vel_j2 = reference(4);
            Sp_acc_j1 = reference(5);
            Sp_acc_j2 = reference(6);

        %------------------------------------------------------------------
        %calcolo azione di controllo del loop esterno 
        %con feedforward di velocità
            Upi_pos1 = ;
            Upi_pos2 = ;

        %------------------------------------------------------------------
        %calcolo azione  di feedfoward
            T_ff = idynRigid(Sp_pos_j1,Sp_pos_j2,Upi_pos1,Upi_pos2,Sp_acc_j1,Sp_acc_j2,0);

        %------------------------------------------------------------------
        %calcolo azione di controllo del loop interno
        %con feedforward di coppia
        Torque1 =
        Torque2 =      

        % azione di controllo giunto 1
        u(1,1) = Torque1;
        % azione di controllo giunto 2
        u(2,1) = Torque2;

        end
    end
end

