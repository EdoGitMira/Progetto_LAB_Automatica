classdef PI_FN_FBP < BaseController
    %controllore PI con l'implementazione di un filtro notch e di un filtro
    %passa basso
    properties
        %parametri controllore
        UMax   % valore massimo dell'azione di controllo filtrata
        Kp     % costante azione di controllo proporzionale      
        Ki     % costante azione di controllo integrale
        xi     % memoria per l'azione integrale
        Kaw    % costante utilizzate per l'anti-windup
        
        %parametri dei filtri
        wn     % w del filtro notch
        xci_p  % parametro dei poli del filtro notch 
        xci_z  % parametro degli zeri del filtro notch 
        Tf     %tau del filtro passa basso
        
        %parametri conversione per il filtro passa basso nella
        %discretizzazione
        nu_fpb    %u in ingresso al filtro pb a t
        num1_fpb  %u in ingresso al filtro pb a t-1
        ny_fpb    %y in uscita al filtro pb a t
        nym1_fpb  %y in uscita al filtro pb a t-1
        
        %parametri conversione per filtro notch nella
        %discretizzazione
        nu_fn    %u in ingresso al filtro notch a t
        num1_fn  %u in ingresso al filtro notch a t-1
        num2_fn  %u in ingresso al filtro notch a t-2
        ny_fn    %y in uscita al filtro notch a t
        nym1_fn  %y in uscita al filtro notch a t-1
        nym2_fn  %y in uscita al filtro notch a t-2

        % buffer di memoria per calcolo dell'azione di controllo discretizzata
        um1        %memoria ingresso filtro notch istante t-1
        um2        %memoria ingresso filtro notch istante t-2
        um1_notch  %memoria uscita filtro notch istante t-1
        um2_notch  %memoria uscita filtro notch istante t-1
        um1_pb     %memoria uscita filtro passa basso t-1
    end
    
    methods
        function obj = PI_FN_FBP(st,Kp,Ki,Kaw,Wn,xci_z,xci_p,Tf)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0

            %_______check input____________________________________________
            assert(isscalar(st));
            assert(st>0);
            assert(isscalar(Kp));
            assert(Kp>0);
            assert(isscalar(Ki));
            assert(Ki>=0);
            assert(isscalar(Kaw));
            assert(Kaw>=0);
            assert(isscalar(Wn));
            assert(Wn>=0);
            assert(isscalar(xci_p));
            assert(xci_p>=0);
            assert(isscalar(xci_z));
            assert(xci_z>=0);
            assert(isscalar(Tf));
            assert(Tf>=0);
            
            %_______salvataggio dei parametri______________________________
            obj@BaseController(st) 
            obj.Kp = Kp;
            obj.Ki = Ki;
            obj.Kaw = Kaw;
            
            obj.Tf = Tf;
            obj.wn = Wn;
            obj.xci_p = xci_p;
            obj.xci_z = xci_z;

            %_______creazione e discretizzazione dei filtri________________
            DiscretizationFN(obj);%filtro notch
            DiscretizationFPB(obj);%filtro passa basso

            %_______inizializzazione delle memorie della classe____________
            initialize(obj);
        end
       
        %metodo di inizializzazione delle memorie della classe
        function obj = initialize(obj)
            %reset dei valori delle memorie a zero
            obj.xi = 0;
            obj.um1 = 0;
            obj.um2 = 0;
            obj.um2_notch = 0;  
            obj.um1_notch = 0;
            obj.um1_pb = 0;
        end
        
        %metodo di starting della classe per avere una unitial al primo
        %istante di controllo
        function obj = starting(obj,reference,y,uinitial)
            %verifica degli ingressi della funzione
            assert(isscalar(reference));
            assert(isscalar(y));
            assert(isscalar(uinitial));

            %calcolo dell'errore
            error = reference - y;
            obj.xi = uinitial-obj.Kp*error;

            %ipotesi che nei valori di tempo precedenti l'uscita dei filtri 
            %sia pari alla azione di controllo che si vuole attuare
            obj.um1 = uinitial; 
            obj.um1_pb = uinitial;
            obj.um2 = uinitial;
            obj.um2_notch = uinitial;
            obj.um1_notch = uinitial;
        end
        
        %metodo per il setting del valore massimo assumibile dalla
        %varaibile di controllo
        function obj = SetUmax(obj,umax)
            %verifica che umax esista e sia > di 0 per avere un controllo
            assert(isscalar(umax));
            assert(umax>0);
            obj.UMax=umax;
        end
        
        %discretizzazione filtro passa basso
        % y   num(z)
        % _ = ___  -->>   y*den = u*num -->>
        % y(t)=(nu_fpb*u(t)+num1_fpb*u(t-1)-nym1_fpb*y(t-1))/ny_fpb
        % u   den(z)

        %metodo per la discretizzazione del filtro da traformata z a k
        function obj = DiscretizationFPB(obj)
            %creazione filtro in s
            Fpb = tf(1,[obj.Tf 1]);
            %discretizzazione filtro in z
            Fpb_d = c2d(Fpb,obj.st,'tustin');
            %prendo il primo numeratore e e denominatore
            Fpb_d_num = Fpb_d.Numerator{1};
            Fpb_d_den = Fpb_d.Denominator{1};
            %setto i parametri di conversione del filtro
            obj.nu_fpb = Fpb_d_num(1);
            obj.num1_fpb = Fpb_d_num(2);
            obj.ny_fpb = Fpb_d_den(1);
            obj.nym1_fpb = Fpb_d_den(2);
        end

        %discretizzazione filtro notch
        % y   num(z)
        % _ = ___  -->>   y*den = u*num -->>
        % y(t)=(nu_fn*u(t)+num1_fn*u(t-1)+num2_fn*u(t-2)-nym1_fn*y(t-1)-nym2_fn*y(t-2))/ny_fn
        % u   den(z)
       
        %metodo per la discretizzazione del filtro notch da traformata z a k
        function obj = DiscretizationFN(obj)
            %creazione filtro in s
            s=tf('s');
            Fn=(s^2+2*obj.xci_z*obj.wn*s+obj.wn^2)/(s^2+2*obj.xci_p*obj.wn*s+obj.wn^2);
            %discretizzazione filtro in z
            Fn_d = c2d(Fn,obj.st,'tustin');
            %prendo il primo numeratore e e denominatore
            Fn_d_num = Fn_d.Numerator{1};
            Fn_d_den = Fn_d.Denominator{1};
            %setto i parametri di conversione del filtro
            obj.nu_fn = Fn_d_num(1);
            obj.num1_fn=Fn_d_num(2);
            obj.num2_fn=Fn_d_num(3);
            obj.ny_fn = Fn_d_den(1);
            obj.nym1_fn=Fn_d_den(2);
            obj.nym2_fn=Fn_d_den(3);
        end
        
        %metodo per il calcolo della azione di controllo passato il riferimento e 
        %il valore di retroazione 
        function u =  computeControlAction(obj,reference,y_feedback)  
            
            assert(isscalar(reference));
            assert(isscalar(y_feedback));
            %calcolo errore in ingresso al PI
            error = reference - y_feedback;

            %calcolo della azione di controllo del PI
            u_now = obj.xi + obj.Kp*error;

            % applicazione filtro notch
            unotch = (obj.nu_fn*u_now + obj.num1_fn*obj.um1 + obj.num2_fn*obj.um2 - obj.nym1_fn*obj.um1_notch - obj.nym2_fn*obj.um2_notch)/obj.ny_fn;
            
            % applicazione filtro passa-basso
            un = (obj.nu_fpb*unotch + obj.num1_fpb*obj.um1_notch - obj.nym1_fpb*obj.um1_pb)/obj.ny_fpb;
            
            % check azione di controllo per la verifica della saturazione
            % in caso affermativo azione di anti-windup
            if (un > obj.UMax) %saturazione positiva
                obj.xi = obj.xi + obj.Ki*error*obj.st + obj.Kaw*obj.st*(obj.UMax-un);
                un = obj.UMax;

            elseif (un < -obj.UMax) %saturazione negativa
                obj.xi = obj.xi + obj.Ki*error*obj.st + obj.Kaw*obj.st*(-obj.UMax-un);
                un = -obj.UMax;

            else % assenza saturazione
                obj.xi = obj.xi + obj.Ki*error*obj.st;
            end
            
            % aggiornamento buffer di memoria per l'istante successivo
            obj.um2 = obj.um1; %u(t-2) = u(t-1)
            obj.um1 = u_now;   %u(t-1) = u_now
            obj.um2_notch = obj.um1_notch;
            obj.um1_notch = unotch;          
            obj.um1_pb = un;

            %scrittura variabile di uscita
            u = un;
        end    
    end
end
