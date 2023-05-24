classdef PIController_pos < handle


    properties 
        st
        Kp %valore di azione proporzionale
        Ki %valore di azione integrale
        u_past %valore dell'azione di controllo nell'istante precedente
        e_past %valore dell'errore passato
    end
    
    methods
        function obj = PIController_pos(st,Kp,Ki)
            assert(isscalar(Kp));
            assert(Kp>=0);
            assert(isscalar(Ki));
            assert(Ki>=0);
            assert(isscalar(st));
            assert(st>0);
                      
            obj.Kp=Kp;
            obj.Ki=Ki;
            obj.st = st;
        end
        
        function obj = initialize(obj)
            obj.u_past = 0;
            obj.e_past = 0;
        end

        function obj = starting(obj,reference,y,u)
            obj.u_past = 0;
            obj.e_past = 0;
        end

        function u = computeControlAction(obj,reference,y_feedabck)
            error = reference-y_feedabck;
            %FORMULA ALGORITMO DI  VELOCITA'
            u_now = obj.u_past+obj.Kp.*((1+(obj.Ki*obj.st))*error-obj.e_past);
            %u_now = obj.u_past+obj.Kp.*(error-obj.e_past);
            obj.e_past = error;
            obj.u_past = u_now;
            u = u_now;
            
        end
    end
end