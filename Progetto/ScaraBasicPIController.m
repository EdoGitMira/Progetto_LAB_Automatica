classdef ScaraBasicPIController < BaseController 
    % Implementazione di PI per i due giunti
    properties  (Access = protected)
        PI1
        PI2
    end
    methods
        function obj=ScaraBasicPIController(st,Kp1,Ki1,Kp2,Ki2)
            % INSERIRE ASSERT SE NECESSARIO
            
            obj@BaseController(st);
            obj.PI1=PIController(st,Kp1,Ki1);
            obj.PI2=PIController(st,Kp2,Ki2);
        end

        % setta l'azione di controllo massima
        function setUMax(obj,umax)
            % INSERIRE ASSERT SE NECESSARIO
            obj.umax=umax;
            obj.PI1.setUMax(umax(1)); 
            obj.PI2.setUMax(umax(2)); 
        end
        
        function obj=initialize(obj)
            obj.PI1.initialize();
            obj.PI2.initialize();
        end

        function obj=starting(obj,reference,y,u)
            % INSERIRE ASSERT SE NECESSARIO
            obj.PI1.starting(reference(1),y(1),u(1));
            obj.PI1.starting(reference(2),y(2),u(2));
        end

        function u=computeControlAction(obj,reference,y)
            % INSERIRE ASSERT SE NECESSARIO
            u(1,1)=obj.PI1.computeControlAction(reference(1),y(1));
            u(2,1)=obj.PI2.computeControlAction(reference(2),y(2));
        end
    end
end