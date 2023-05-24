classdef PIController_vel < handle
    %'controllore del secondo loop solo P
    properties
        st
        Kp         
        u_past %valore dell'azione di controllo nell'istante precedente
        e_past %valore dell'errore passato
    end
    
    methods
        function obj = PIController_vel(st,Kp)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0
            assert(isscalar(Kp));
            assert(Kp>=0);
           
            obj.st=st;
            obj.Kp = Kp;


        end
        
        function obj = initialize(obj)

        end

        function obj = starting(obj)
            obj.e_past = 0;
            obj.u_past = 0;
        end

        function u =  computeControlAction(obj,reference,y_feedback)   
            error = reference - y_feedback;
            u_now = obj.u_past+obj.Kp.*(error);
            %u = obj.Kp * error;
            obj.e_past = error;
            obj.u_past = u_now;
            u = u_now;
        end    
    end
end
