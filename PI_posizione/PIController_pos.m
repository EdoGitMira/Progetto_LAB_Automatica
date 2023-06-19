classdef PIController_pos < BaseController
    
    properties (Access = private)
        Kp %valore di azione proporzionale
        Ki %valore di azione integrale
        u_past %valore dell'azione di controllo nell'istante precedente
        e_past %valore dell'errore passato
    end
    
    properties
    
    end
    
    methods
        %metodo per la creazione del controllore PI 
        function obj = PIController_pos(st,Kp,Ki)
            %check input 
            assert(isscalar(Kp));
            assert(Kp>0);
            assert(isscalar(Ki));
            assert(Ki>0);
            assert(isscalar(st));
            assert(st>0);
            %-----------
            obj@BaseController(st)         
            obj.Kp=Kp;
            obj.Ki=Ki;
        end
        
        %inizializzazione dei valori passati
        function obj = initialize(obj)
            obj.u_past = 0;
            obj.e_past = 0;
        end
        
        %funzione per return di Ki
        function out = valKi(obj)
            out = obj.Ki;
        end
        
        %funzione per return di e_past
        function out = valE_past(obj)
            out = obj.e_past;
        end
        
        %funzione per return di e_past
        function out = valU_past(obj)
            out = obj.u_past;
        end
        
        %funzione per return di Kp
        function out = valKp(obj)
            out = obj.Kp;
        end
        
        %funzione per il settaggio del valore di e_past con un valore
        %passato alla funzione
        function obj = setErrPast(obj,err_set)
            assert(isscalar(err_set));
            obj.e_past = err_set;
        end
        
        %funzione per il settaggio del valore di u_past con un valore
        %passato alla funzione
        function obj = setUPast(obj,u_set)
            assert(isscalar(u_set));
            obj.u_past = u_set;
        end
        
        %funzione per inizializzare i valori del pi di posozione
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
        
        %funzione per il calcolo della azione di controllo del controllore
        %implementato con il metodo di implementazione digitale mediante
        %l'utilizzo dell'algoritmo di velocità.
        function u = computeControlAction(obj,reference,y_feedabck)
            assert(isscalar(reference));
            assert(isscalar(y_feedabck));
            error = reference-y_feedabck;
            %FORMULA ALGORITMO DI  VELOCITA'
            u_now = obj.u_past+obj.Kp.*((1+(obj.Ki*obj.st))*error-obj.e_past);
            obj.e_past = error;
            
            % if (abs(u_now)>obj.umax)
            %     if u_now > 0
            %         u_now = obj.umax;
            %     else
            %         u_now = -obj.umax;
            %     end
            % end
            
            obj.u_past = u_now;
            u = u_now;
            
        end
    end
end