classdef PIController < BaseController 
    % Implementazione di PI
    % u=Kp*e+xi
    % xi=xi+Ki*e*st
    properties  (Access = protected)
        xi % integrale(Ki*e*dt)
        Kp 
        Ki 
    end
    methods
        function obj=PIController(st,Kp,Ki)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0
            assert(isscalar(Kp));
            assert(Kp>=0);
            assert(isscalar(Ki));
            assert(Ki>=0);
            assert(isscalar(st));
            assert(st>0);
            
            obj@BaseController(st);

            obj.xi=0;
            obj.Kp=Kp;
            obj.Ki=Ki;
        end
        
        function obj=initialize(obj)
            obj.xi=0;
        end

        function obj=starting(obj,reference,y,u)
            % verifico correttezza degli ingressi.
            % questo controllore richiede che reference,y e u siano scalari
            assert(isscalar(reference));
            assert(isscalar(y));
            assert(isscalar(u));
            
            % inizializzo l'azione integrale con implementazione bumbless
            % u=xi+Kp*e -> xi=u-Kp*e
            e=reference-y;
            obj.xi=u-obj.Kp*e;
        end

        function u=computeControlAction(obj,reference,y)
            % verifico correttezza degli ingressi.
            % questo controllore richiede che reference,y e u siano scalari
            assert(isscalar(reference));
            assert(isscalar(y));
            
            e=reference-y;
            
            u=obj.xi+obj.Kp*e;
            %occhio alla azione antiwindup e sfrutto una integrazione
            %condizionata in base alle condizioni per uscire dalle varie
            %fasi critiche della integrazione.
            if (u>obj.umax)
                u=obj.umax;
                if (e<0) % integrazione condizionata
                    obj.xi=obj.xi+obj.Ki*obj.st*e;
                end
            elseif (u<-obj.umax)
                u=-obj.umax;
                if (e>0) % integrazione condizionata
                    obj.xi=obj.xi+obj.Ki*obj.st*e;
                end
            else
                obj.xi=obj.xi+obj.Ki*obj.st*e;
            end
        end
    end
end