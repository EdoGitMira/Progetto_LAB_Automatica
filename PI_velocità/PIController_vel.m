classdef PIController_vel < BaseController
    %'controllore del secondo loop solo P
    properties
        Kp     %valore del azione di controllo proporzionale      
        %u_past %valore dell'azione di controllo nell'istante precedente
        %e_past %valore dell'errore passato
        Umax
    end
    
    methods
        function obj = PIController_vel(st,Kp)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0
            %check input
            assert(isscalar(Kp));
            assert(Kp>0);
            assert(isscalar(st));
            assert(st>0);
            %------------
            obj@BaseController(st) 
            obj.Kp = Kp;

        end
       
        function obj = initialize(obj)
        end

        function obj = starting(obj)
        end
        
        function obj = SetUmax(umax)
            assert(isscalar(umax));
            assert(umax>0);
            obj.Umax=umax;
        end
        

        function u =  computeControlAction(obj,reference,y_feedback)  
            assert(isscalar(reference));
            assert(isscalar(y_feedback));
            
            error = reference - y_feedback;
            u_now = obj.Kp*(error);
            %obj.e_past = error;
            %obj.u_past = u_now;
            if abs(u_now)>obj.Umax
                if u_now > 0
                    u_now = obj.Umax; 
                else
                    u_now = -obj.Umax;
                end
            end
            u = u_now;
        end    
    end
end
