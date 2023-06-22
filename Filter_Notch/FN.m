classdef FN < BaseController
    %FN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        wn 
        xci_p
        xci_z

        a   % costanti filtro notch
        b
        c
        d
        f
        g
    end
    
    methods
        function obj = FN(st,Wn,xci_z,xci_p)
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
            obj.wn = Wn;
            obj.xci_p = xci_p;
            obj.xci_z = xci_z;
            DiscretizationFN(obj);
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

        function u =  computeControlAction(obj,reference)  
            % applicazione filtro notch
            un = (obj.a*reference + obj.b*obj.u_m1 + obj.c*obj.u_m2 - obj.f*obj.unotch_m1 - obj.g*obj.unotch_m2)/obj.d;
            
            % aggiornamento buffer di memoria per filtri
            obj.u_m2 = obj.u_m1;
            obj.u_m1 = reference; 

            obj.unotch_m2 = obj.unotch_m1;
            obj.unotch_m1 = un;
            
            u = un;
        end  
    end
end

