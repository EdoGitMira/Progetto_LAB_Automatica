classdef FilterNotch < handle
    %FILTERNOTCH classe per l'impementazione del filtro notch.
    % nella forma di :
    % (s^2+2*xci_z*wn*s+wn^2)/(s^2+2*xci_p*wn*s+wn^2);
    %
    %una volta chiamato il filtro richiamare la funzione discretizzazione
    %se serve il filtro in z 
    %e successivamente richiamare la funzione di starning per inizializzare
    %i valori per il calcolo del'uscita che sono inizializzazi in base al
    %valore di dc gain del filtro.
    
    properties 
        st %tempo di campionamento

        %parametri del filtro
        wn     % w del filtro notch
        xci_p  % parametro dei poli del filtro notch 
        xci_z  % parametro degli zeri del filtro notch 

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
    end
    
    methods
        %metodo per l'inizializzazione della classe dove creiemi il filtro
        %in constinua
        function obj = FilterNotch(st,Wn,xci_z,xci_p)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0

            %_______check input____________________________________________
            assert(isscalar(st));
            assert(st>0);
            assert(isscalar(Wn));
            assert(Wn>=0);
            assert(isscalar(xci_p));
            assert(xci_p>=0);
            assert(isscalar(xci_z));
            assert(xci_z>=0);
           
            %_______salvataggio dei parametri______________________________
            obj.st = st;
            obj.wn = Wn;
            obj.xci_p = xci_p;
            obj.xci_z = xci_z;

            %_______creazione e discretizzazione dei filtri________________
            DiscretizationFN(obj);%filtro notch

            %_______inizializzazione delle memorie della classe____________
            initialize(obj);
        end
       
        %metodo di inizializzazione delle memorie della classe
        function obj = initialize(obj)
            %reset dei valori delle memorie a zero
            obj.um1 = 0;
            obj.um2 = 0;
            obj.um2_notch = 0;  
            obj.um1_notch = 0;
        end
        
        %metodo di starting della classe per avere una unitial al primo
        %istante di controllo
        function obj = starting(obj,uinitial)
            %verifica degli ingressi della funzione
            assert(isscalar(uinitial));

            %ipotesi che nei valori di tempo precedenti l'uscita del filtro 
            %sia pari alla azione di controllo che si vuole attuare
            obj.um1 = uinitial; 
            obj.um2 = uinitial;
            obj.um2_notch = uinitial;
            obj.um1_notch = uinitial;
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
        function u =  computeAction(obj,reference)
            assert(isscalar(reference));

            % applicazione filtro notch
            un = (obj.nu_fn*reference + obj.num1_fn*obj.um1 + obj.num2_fn*obj.um2 - obj.nym1_fn*obj.um1_notch - obj.nym2_fn*obj.um2_notch)/obj.ny_fn;
            
            % aggiornamento buffer di memoria per l'istante successivo
            obj.um2 = obj.um1; %u(t-2) = u(t-1)
            obj.um1 = reference;   %u(t-1) = u_now
            obj.um2_notch = obj.um1_notch;
            obj.um1_notch = un;          

            %scrittura variabile di uscita
            u = un;
        end    
    end
end

