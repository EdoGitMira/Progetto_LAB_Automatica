classdef PIController_pos < BaseController


    properties 
        Kp %valore di azione proporzionale
        Ki %valore di azione integrale
        u_past %valore dell'azione di controllo nell'istante precedente
        e_past %valore dell'errore passato
    end
    
    methods
        function obj = PIController_pos(st,Kp,Ki)
            assert(isscalar(Kp));
            assert(Kp>0);
            assert(isscalar(Ki));
            assert(Ki>0);
            assert(isscalar(st));
            assert(st>0);
            
            obj@BaseController(st)         
            obj.Kp=Kp;
            obj.Ki=Ki;
            
        end
        
        function obj = initialize(obj)
            obj.u_past = 0;
            obj.e_past = 0;
        end

        function obj = starting(obj,reference,y_feedback,uinitial)
            % verifico correttezza degli ingressi.
            % si richiede che reference,y e u siano scalari
            assert(isscalar(reference));
            assert(isscalar(y_feedback));
            assert(isscalar(uinitial));
            
            % inizializzo l'azione integrale con implementazione bumbless
            error = reference-y_feedback;
            %u=Kp*e+ Kp*Ki*st*e
            
            u_now = uinitial- obj.Kp.*((1+(obj.Ki*obj.st))*error);
            
            obj.u_past = u_now;
            obj.e_past = 0;
        end

        function u = computeControlAction(obj,reference,y_feedabck)
            error = reference-y_feedabck;
            %FORMULA ALGORITMO DI  VELOCITA'
            u_now = obj.u_past+obj.Kp.*((1+(obj.Ki*obj.st))*error-obj.e_past);
            %u_now = obj.u_past+obj.Kp.*(error-obj.e_past);
            obj.e_past = error;
            
            if (abs(u_now)>obj.umax)
                if u_now > 0
                    u_now = obj.umax;
                else
                    u_now = -obj.umax;
                end
            end
            
            obj.u_past = u_now;
            u = u_now;
            
        end
    end
end