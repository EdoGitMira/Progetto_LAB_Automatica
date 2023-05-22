classdef PIController_vel < BaseController 
    %'controllore del secondo loop solo P
    properties
        Kp 
        e_past
        u_past
    end
    
    methods
        function obj = PIController_vel(st,Kp)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0
            assert(isscalar(Kp));
            assert(Kp>=0);
           
            obj@BaseController(st);
            obj.Kp = Kp;


        end
        
        function obj = initialize(obj)

        end

        function obj = starting(obj)

        end

        function u =  computeControlActionDis(obj,reference,y_feedback)   
            error = reference - y_feedback;
            u = obj.Kp * error;
        end    
    end
end
