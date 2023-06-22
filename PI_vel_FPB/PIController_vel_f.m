classdef PIController_vel_f < BaseController
    %'controllore del secondo loop solo P
    properties
        Kp     % valore del azione di controllo proporzionale      
        UMax   % valore massimo dell'azione di controllo filtrata

        Tf %tau del filtro
        Fs %filtro in continua
        Fd %filtro in discreto
        
        j   % costanti filtro passa basso
        k
        l
        m

        u_m1    % buffer di memoria per filtro
        un_m1

    end
    
    methods
        function obj = PIController_vel_f(st,Kp,Tf)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0
            %check input
            assert(isscalar(Kp));
            assert(Kp>0);
            assert(isscalar(Tf));
            assert(Tf>=0);
            assert(isscalar(st));
            assert(st>0);
            %------------
            obj@BaseController(st) 
            obj.Kp = Kp;
            obj.Tf = Tf;
            Discretization(obj);
            
        end
       
        function obj = initialize(obj)
            % obj.UoutPast = zeros(length(obj.A),1)*dcgain(obj.Fs);
            % obj.UinPast = zeros(length(obj.B),1)*dcgain(obj.Fs);
            obj.u_m1 = 0;
            obj.un_m1 = 0;
        end
        %inzializzazione del filtro
        function obj = starting(obj,reference,y,uinitial)
            assert(isscalar(reference));
            assert(isscalar(y));
            assert(isscalar(uinitial));

            error = reference - y;
            obj.u_m1 = 0; % ipotizzo u_m1 = 0
            obj.un_m1 = (obj.j*obj.Kp*error - uinitial)/obj.m;
        end
        
        %funzine per il setting del valore massimo assumibile dalla
        %varaibile di controllo
        function obj = SetUmax(obj,umax)
            assert(isscalar(umax));
            assert(umax>0);
            obj.UMax=umax;
        end
        
        %funzione per la discretizzazione del filtro nella traformata z e
        %per il calcolo della delle matriici A e B
        function obj = Discretization(obj)
            Fpb = tf(1,[obj.Tf 1]);
            Fpb_disc = c2d(Fpb,obj.st,'tustin');
            num_fpb = Fpb_disc.Numerator{1};
            den_fpb = Fpb_disc.Denominator{1};
            
            obj.j = num_fpb(1);
            obj.k = num_fpb(2);
            obj.l = den_fpb(1);
            obj.m = den_fpb(2);

            obj.u_m1 = 0;
            obj.un_m1 = 0;
        end

        function u =  computeControlAction(obj,reference,y_feedback)  
            
            assert(isscalar(reference));
            assert(isscalar(y_feedback));
            
            error = reference - y_feedback;
            u_now = obj.Kp*(error);

            % applicazione filtro passa basso
            un = (obj.j*u_now + obj.k*obj.u_m1 - obj.m*obj.un_m1)/obj.l;
           
            if abs(un)>obj.UMax
                if un > 0
                    un = obj.UMax; 
                else
                    un =-obj.UMax;
                end
            end
            u = un;
            % aggiornamento buffer
            obj.u_m1 = u_now;
            obj.un_m1 = un;
        end    
    end
end
