classdef FilterNotch < handle
    %FILTERNOTCH classe per l'impementazione del filtro notch.
    
    properties
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
    
    methods
        function obj = FilterNotch(w,xc_z,xc_p,St)
            obj.wn = w;
            obj.xci_z=xc_z; 
            obj.xci_p=xc_p;
            obj.St = St;
            s=tf('s');
            obj.Fs =(s^2+2*obj.xci_z*obj.wn*s+obj.wn^2)/(s^2+2*obj.xci_p*obj.wn*s+obj.wn^2);
        end
        
        function obj = Discretization(obj)
            
            obj.Fd = c2d(obj.Fs,obj.St);
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
        
        function obj = Starting(obj)
            obj.UoutPast = ones(length(obj.A),1)*dcgain(obj.Fs);
            obj.UinPast = ones(length(obj.B),1)*dcgain(obj.Fs);
        end
        
        function out = Compute(obj,reference)
            outcalc = obj.A*obj.UoutPast+obj.B*obj.UinPast;
            
            for i = length(obj.UinPast):-1:2
                   obj.UinPast(i) = obj.UinPast(i-1);
            end
            obj.UinPast(1) = reference;
            
           
            for i = length(obj.UoutPast):-1:2
                obj.UoutPast(i) = obj.UoutPast(i-1);
            end
            obj.UoutPast(1) = outcalc;
            
            out = outcalc;
        end
        
    end
end

