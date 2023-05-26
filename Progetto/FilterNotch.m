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
    
    properties (Access = private) 
        St %tempo di campionamento
        wn %omega del filtro
        xci_z %per rendere il filtro più o meno selettivo
        xci_p %per rendere il filtro più o meno selettivo
        UinPast %valori precedenti in ingresso al filtro
        UoutPast %valori prededenti del filtro in uscita
        Fs %filtro in continua
        Fd %filtro in discreto
        A %vettore parametri per discretizzazione rispetto a y
        B %vettore parametri per discretizzazione rispetto a u
    end
    
    properties
        
    end
    
    methods
        %metodo per l'inizializzazione della classe dove creiemi il filtro
        %in constinua
        function obj = FilterNotch(w,xc_z,xc_p,St)
            %check input
            assert(isscalar(w));
            assert(w>0);
            assert(isscalar(xc_z));
            assert(xc_z>0);
            assert(isscalar(xc_p));
            assert(xc_p>0);
            assert(isscalar(St));
            assert(St>0);
            %----------
            obj.wn = w;
            obj.xci_z=xc_z; 
            obj.xci_p=xc_p;
            obj.St = St;
            s=tf('s');
            obj.Fs =(s^2+2*obj.xci_z*obj.wn*s+obj.wn^2)/(s^2+2*obj.xci_p*obj.wn*s+obj.wn^2);
        end
        
        %funzione di starting dove si setta il valore iniziale del filtro
        %che viene posto pari al valore di guadagno 
        function obj = Starting(obj)
            obj.UoutPast = ones(length(obj.A),1)*dcgain(obj.Fs);
            obj.UinPast = zeros(length(obj.B),1)*dcgain(obj.Fs);
        end
        
        %funzione per la discretizzazione del filtro nella traformata z e
        %pe ril calcolo della delle matriici A e B
        function obj = Discretization(obj)
            
            obj.Fd = c2d(obj.Fs,obj.St,'tustin');
            obj.Fd.Variable='z^-1';
            %calcolo i coefficienti di A e di B
            numC0d = obj.Fd.Numerator{1};
            denC0d = obj.Fd.Denominator{1};
            numC0d = numC0d/denC0d(1);
            denC0d = denC0d/denC0d(1);
            
            %y/u = B/A
            obj.A = -denC0d(2:end); %uscite precenti
            obj.B = numC0d; % incressi precedenti
        end
        
        %funzione per ritornare wn
        function out = Wn(obj)
            out  = obj.Wn;
        end 
        
        %funzione per ritornare il valore del polo 
        function out = Xp(obj)
            out  = obj.xci_p;
        end 
        
        %funzione per ritornare il valore dello zero 
        function out = Xz(obj)
            out  = obj.xci_z;
        end 
        
        %funzione per ritornare la funzione di trasferimento in s
        function out = TransferFunctionC(obj)
            out  = obj.Fs;
        end 
        
        %funzione per ritornare la funzione di trasferimento in z
        function out = TransferFunctionD(obj)
            out  = obj.Fd;
        end 
        
        %funzione per il calcolo del 'uscita del filtro che viene calcolata
        %con il valore passato di reference e considerando i valori passati
        %diingresso e uscita del filtro
        function out = Compute(obj,reference)
            outcalc = obj.A*obj.UoutPast+obj.B*obj.UinPast;
            
            %aggiornamento dei valori dell'ingresso passati
            for i = length(obj.UinPast):-1:2
                   obj.UinPast(i) = obj.UinPast(i-1);
            end
            obj.UinPast(1) = reference;
            
            %aggiornamento dei valori di uscita passati
            for i = length(obj.UoutPast):-1:2
                obj.UoutPast(i) = obj.UoutPast(i-1);
            end
            obj.UoutPast(1) = outcalc;
            
            %scrittura dell'uscita attuale calcolata
            out = outcalc;
        end
        
    end
end

