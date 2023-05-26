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
    
    properties (Access = private) 
        St %tempo di campionamento
        Tf %tau del filtro
        UinPast %valori precedenti in ingresso al filtro
        UoutPast %valori prededenti del filtro in uscita
        Fs %filtro in continua
        Fd %filtro in discreto
        A %vettore parametri per discretizzazione rispetto a y
        B %vettore parametri per discretizzazione rispetto a u
    end
    
    methods
        
        %metodo per l'inizializzazione della classe dove creiemi il filtro
        %in constinua
        function obj = FilterFirstOrder(Tf,St)
            %check input
            assert(isscalar(Tf));
            assert(Tf>0);
            assert(isscalar(St));
            assert(St>0);
            %------------
            obj.Tf = Tf;
            obj.St = St;
            s  = tf('s');
            obj.Fs = 1/(1+s*obj.Tf);
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
        
        %funzione per ritornare la funzione di trasferimento in s
        function out = TF(obj)
            out  = obj.Tf;
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

