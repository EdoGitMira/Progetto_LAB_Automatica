classdef PI < BaseController
    %controllore PI con l'implementazione di un filtro notch e di un filtro
    %passa basso
    properties
        %parametri controllore
        UMax   % valore massimo dell'azione di controllo filtrata
        Kp     % costante azione di controllo proporzionale      
        Ki     % costante azione di controllo integrale
        xi     % memoria per l'azione integrale
        Kaw    % costante utilizzate per l'anti-windup
   end
    
    methods
        function obj = PI(st,Kp,Ki,Kaw)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0

            %_______check input____________________________________________
            assert(isscalar(st));
            assert(st>0);
            assert(isscalar(Kp));
            assert(Kp>0);
            assert(isscalar(Ki));
            assert(Ki>=0);
            assert(isscalar(Kaw));
            assert(Kaw>=0);
                       
            %_______salvataggio dei parametri______________________________
            obj@BaseController(st) 
            obj.Kp = Kp;
            obj.Ki = Ki;
            obj.Kaw = Kaw;
            %_______inizializzazione delle memorie della classe____________
            initialize(obj);
        end
       
        %metodo di inizializzazione delle memorie della classe
        function obj = initialize(obj)
            %reset dei valori delle memorie a zero
            obj.xi = 0;
        end
        
        %metodo di starting della classe per avere una unitial al primo
        %istante di controllo
        function obj = starting(obj,reference,y,uinitial)
            %verifica degli ingressi della funzione
            assert(isscalar(reference));
            assert(isscalar(y));
            assert(isscalar(uinitial));

            %calcolo dell'errore
            error = reference - y;
            obj.xi = uinitial-obj.Kp*error;
        end
        
        %metodo per il setting del valore massimo assumibile dalla
        %varaibile di controllo
        function obj = SetUmax(obj,umax)
            %verifica che umax esista e sia > di 0 per avere un controllo
            assert(isscalar(umax));
            assert(umax>0);
            obj.UMax=umax;
        end
        
        
        
        %metodo per il calcolo della azione di controllo passato il riferimento e 
        %il valore di retroazione 
        function u =  computeControlAction(obj,reference,y_feedback)  
            
            assert(isscalar(reference));
            assert(isscalar(y_feedback));
            %calcolo errore in ingresso al PI
            error = reference - y_feedback;

            %calcolo della azione di controllo del PI
            un = obj.xi + obj.Kp*error;

            % check azione di controllo per la verifica della saturazione
            % in caso affermativo azione di anti-windup
            if (un > obj.UMax) %saturazione positiva
                obj.xi = obj.xi + obj.Ki*error*obj.st + obj.Kaw*obj.st*(obj.UMax-un);
                un = obj.UMax;
            elseif (un < -obj.UMax) %saturazione negativa
                obj.xi = obj.xi + obj.Ki*error*obj.st + obj.Kaw*obj.st*(-obj.UMax-un);
                un = -obj.UMax;
            else % assenza saturazione
                obj.xi = obj.xi + obj.Ki*error*obj.st;
            end

            %scrittura variabile di uscita
            u = un;
        end    
    end
end
