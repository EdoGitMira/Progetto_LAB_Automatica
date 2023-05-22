classdef FilterFirstOrder < handle
    %FILTERFIRSTORDER classe per l'impementazione del filtro del primo.
    
    properties
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
        function obj = FilterFirstOrder(Tf,St)
            obj.Tf = Tf;
            obj.St = St;
            s  = tf('s');
            obj.Fs = 1/(1+s*obj.Tf);
        end    
        
        function obj = Discretization(obj)
            
            obj.Fd = c2d(obj.Fs,obj.St);
            %calcolo i coefficienti di A e di B
            numC0d = obj.Fd.Numerator{1};
            denC0d = obj.Fd.Denominator{1};
            numC0d = numC0d/denC0d(1);
            denC0d = denC0d/denC0d(1);
            
            %y/u = B/A
            obj.A = -denC0d(2:end); %uscite precenti
            obj.B = numC0d; % incressi precedenti
            % y = A*y(k-x)+B*u(k-x)
            % y = 0.4493*y(k-1) + 0.5507*u(k-1)
        end
        
        %inizalizzazione dei valori precedenti del filtro come se fosse a
        %regime
        function obj = Starting(obj)
            obj.UoutPast = ones(length(obj.A),1)*dcgain(obj.Fs);
            obj.UinPast = ones(length(obj.B),1)*dcgain(obj.Fs);
        end
        
        function out = Compute(obj,reference)
            outcalc = obj.A*obj.UoutPast+obj.B*obj.UinPast;
            
            for i = (1:length(obj.UinPast)-1)
                   obj.UinPast(i) = obj.UinPast(i+1);
            end
            obj.UinPast(end) = reference;
            
           
            for i = 1:(length(obj.UoutPast)-1)
                obj.UoutPast(i) = obj.UoutPast(i+1);
            end
            obj.UoutPast(end) = outcalc;
            
            out = outcalc;
        end
    end
end

