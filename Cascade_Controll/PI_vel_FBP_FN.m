classdef PI_vel_FBP_FN < BaseController
    %'controllore del secondo loop solo P
    properties
        Kp     % valore del azione di controllo proporzionale      
        UMax   % valore massimo dell'azione di controllo filtrata

        wn 
        xci_p
        xci_z

        Tf       %tau del filtro

        j   % costanti filtro passa basso
        k
        l
        m

        a   % costanti filtro notch
        b
        c
        d
        f
        g

        u_m1    % buffer di memoria per filtri
        u_m2
        unotch_m1
        unotch_m2
        un_m1
        un_m2

    end
    
    methods
        function obj = PI_vel_FBP_FN(st,Kp,Tf,Wn,xci_z,xci_p)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0
            %check input
            assert(isscalar(Kp));
            assert(Kp>0);
            assert(isscalar(Tf));
            assert(Tf>=0);
            assert(isscalar(Wn));
            assert(Wn>=0);
            assert(isscalar(xci_p));
            assert(xci_p>=0);
            assert(isscalar(xci_z));
            assert(xci_z>=0);
            assert(isscalar(st));
            assert(st>0);
            %------------
            obj@BaseController(st) 
            obj.Kp = Kp;
            obj.Tf = Tf;
            obj.wn = Wn;
            obj.xci_p = xci_p;
            obj.xci_z = xci_z;
            DiscretizationFPB(obj);
            DiscretizationFN(obj);

        end
       
        function obj = initialize(obj)
            obj.u_m1 = 0;
            obj.u_m2 = 0;
            obj.unotch_m2 = 0;  
            obj.unotch_m1 = 0;
            obj.un_m1 = 0;
            obj.un_m2 = 0;
        end
        
        %inzializzazione del filtro
        function obj = starting(obj,reference,y,uinitial)
            assert(isscalar(reference));
            assert(isscalar(y));
            assert(isscalar(uinitial));

            obj.u_m1 = uinitial; % ipotizzo u_m1 = 0
            obj.un_m1 = uinitial;
            obj.u_m2 = uinitial;
            obj.un_m2 = uinitial;
            obj.unotch_m2 = uinitial;
            obj.unotch_m1 = uinitial;
        end
        
        %funzine per il setting del valore massimo assumibile dalla
        %varaibile di controllo
        function obj = SetUmax(obj,umax)
            assert(isscalar(umax));
            assert(umax>0);
            obj.UMax=umax;
        end
        
        %funzione per la discretizzazione del filtro nella traformata z a k
        function obj = DiscretizationFPB(obj)
            Fpb = tf(1,[obj.Tf 1]);
            Fpb_disc = c2d(Fpb,obj.st,'tustin');
            num_fpb = Fpb_disc.Numerator{1};
            den_fpb = Fpb_disc.Denominator{1};
            
            obj.j = num_fpb(1);
            obj.k = num_fpb(2);
            obj.l = den_fpb(1);
            obj.m = den_fpb(2);
        end

        %funzione per la discretizzazione del filtro nella traformata z a k
        function obj = DiscretizationFN(obj)
            s=tf('s');
            notch=(s^2+2*obj.xci_z*obj.wn*s+obj.wn^2)/(s^2+2*obj.xci_p*obj.wn*s+obj.wn^2);
            notch_disc = c2d(notch,obj.st,'tustin');
            num_notch = notch_disc.Numerator{1};
            den_notch = notch_disc.Denominator{1};
            obj.a = num_notch(1);
            obj.b = num_notch(2);
            obj.c = num_notch(3);
            obj.d = den_notch(1);
            obj.f = den_notch(2);
            obj.g = den_notch(3);
        end

        function u =  computeControlAction(obj,reference,y_feedback)  
            
            assert(isscalar(reference));
            assert(isscalar(y_feedback));
            
            error = reference - y_feedback;

            u_now = obj.Kp*(error);

            % applicazione filtro notch
            unotch = (obj.a*u_now + obj.b*obj.u_m1 + obj.c*obj.u_m2 - obj.f*obj.unotch_m1 - obj.g*obj.unotch_m2)/obj.d;
            % applicazione filtro passa-basso
            un = (obj.j*unotch + obj.k*obj.unotch_m1 - obj.m*obj.un_m1)/obj.l;
            
          
            if abs(un)>obj.UMax
                if un > 0
                    un = obj.UMax; 
                else
                    un =-obj.UMax;
                end
            end
            
            % aggiornamento buffer di memoria per filtri
            obj.u_m2 = obj.u_m1;
            obj.u_m1 = u_now; 

            obj.unotch_m2 = obj.unotch_m1;
            obj.unotch_m1 = unotch;
            
            obj.un_m2 = obj.un_m1;
            obj.un_m1 = un; 

            u = un;
        end    
    end
end
