classdef FilterFirstOrder < handle
    %FILTERFIRSTORDER classe per l'impementazione del filtro del primo.
    % nella forma di :
    % 1/(1+s*Tf)
    %
    %una volta chiamato il filtro richiamare la funzione discretizzazione
    %se serve il filtro in z 
    %e successivamente richiamare la funzione di starning per inizializzare
    %i valori per il calcolo del'uscita che sono inizializzazi in base al
    %valore di dc gain del filtro.
    
    properties
        st %tempo di campionamento

        %parametri del filtro
        Tf       %tau del filtro passa basso
        
        %parametri conversione per filtro passa basso
        nu_fpb   
        num1_fpb
        ny_fpb
        nym1_fpb
        
        % buffer di memoria per calcolo dell'azione di controllo discretizzata
        um1        %memoria ingresso filtro passa basso t-1
        um1_pb     %memoria uscita filtro passa basso t-1
    end
    
    methods
        function obj = FilterFirstOrder(st,Tf)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0

            %_______check input____________________________________________
            assert(isscalar(st));
            assert(st>0);
           
            assert(isscalar(Tf));
            assert(Tf>=0);
            
            %_______salvataggio dei parametri______________________________
            obj.st = st; 
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
        function obj = starting(obj,uinitial)
            assert(isscalar(uinitial));
            obj.um1 = uinitial; 
            obj.um1_pb = uinitial;
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
            %setto i parsmtri di conversione del filtro
            obj.nu_fpb = Fpb_d_num(1);
            obj.num1_fpb = Fpb_d_num(2);
            obj.ny_fpb = Fpb_d_den(1);
            obj.nym1_fpb = Fpb_d_den(2);
        end

                
        %metodo per il calcolo della azione di controllo passato il riferimento
        function u =  computeAction(obj,reference)  
            assert(isscalar(reference));
            
            % applicazione filtro passa-basso
            un = (obj.nu_fpb*reference + obj.num1_fpb*obj.um1 - obj.nym1_fpb*obj.um1_pb)/obj.ny_fpb;
                       
            % aggiornamento buffer di memoria per l'istante successivo
            obj.um1 = reference;   %u(t-1) = u_now
            obj.um1_pb = un;

            %scrittura variabile di uscita
            u = un;
        end    
    end
end

