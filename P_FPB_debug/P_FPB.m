classdef P_FPB < BaseController
    %controllore PI con l'implementazione di un filtro notch e di un filtro
    %passa basso
    properties
        %parametri controllore
        UMax   % valore massimo dell'azione di controllo filtrata
        Kp     % costante azione di controllo proporzionale      

        %parametri dei filtro
        Tf       %tau del filtro passa basso
        
        %parametri conversione per filtro passa basso
        nu_fpb   
        num1_fpb
        ny_fpb
        nym1_fpb
        
        % buffer di memoria per calcolo dell'azione di controllo discretizzata
        um1        %memoria ingresso filtro passa basso istante t-1
        um1_pb     %memoria uscita filtro passa basso t-1
    end
    
    methods
        function obj = P_FPB(st,Kp,Tf)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0

            %_______check input____________________________________________
            assert(isscalar(st));
            assert(st>0);
            assert(isscalar(Kp));
            assert(Kp>0);
            assert(isscalar(Tf));
            assert(Tf>=0);
            
            %_______salvataggio dei parametri______________________________
            obj@BaseController(st) 
            obj.Kp = Kp;         
            obj.Tf = Tf;
            
            %_______creazione e discretizzazione del filtro________________
            DiscretizationFPB(obj);%filtro passa basso

            %_______inizializzazione delle memorie della classe____________
            initialize(obj);
        end
       
        %metodo di inizializzazione delle memorie della classe
        function obj = initialize(obj)
            %reset dei valori delle memorie a zero
            obj.um1 = 0;
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

            %ipotesi che nei valori di tempo precedenti l'uscita dei filtri 
            %sia pari alla azione di controllo che si vuole attuare
            obj.um1 = 0; 
            obj.um1_pb = (obj.nu_fpb*obj.Kp*error-uinitial)/obj.nym1_fpb;
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

        
        %metodo per il calcolo della azione di controllo passato il riferimento e 
        %il valore di retroazione 
        function u =  computeControlAction(obj,reference,y_feedback)  
            
            assert(isscalar(reference));
            assert(isscalar(y_feedback));
            %calcolo errore in ingresso al PI
            error = reference - y_feedback;

            %calcolo della azione di controllo del PI
            u_now = obj.Kp*error;

            % applicazione filtro passa-basso
            un = (obj.nu_fpb*u_now + obj.num1_fpb*obj.um1 - obj.nym1_fpb*obj.um1_pb)/obj.ny_fpb;
            
            % check azione di controllo per la verifica della saturazione
            % in caso affermativo azione di anti-windup
            if (un > obj.UMax) %saturazione positiva
                un = obj.UMax;
            elseif (un < -obj.UMax) %saturazione negativa
                un = -obj.UMax;
            end
            
            % aggiornamento buffer di memoria per l'istante successivo
            obj.um1 = u_now;   %u(t-1) = u_now       
            obj.um1_pb = un;

            %scrittura variabile di uscita
            u = un;
        end    
    end
end
