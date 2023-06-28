classdef P < BaseController
    %controllore PI con l'implementazione di un filtro notch e di un filtro
    %passa basso
    properties
        %parametri controllore
        UMax   % valore massimo dell'azione di controllo filtrata
        Kp     % costante azione di controllo proporzionale      
    end
    
    methods
        function obj = P(st,Kp)
            % verifico correttezza parametri
            % che siano dei numeri e scalari e che siano >=0

            %_______check input____________________________________________
            assert(isscalar(st));
            assert(st>0);
            assert(isscalar(Kp));
            assert(Kp>0);
        
            %_______salvataggio dei parametri______________________________
            obj@BaseController(st) 
            obj.Kp = Kp;         

        end
       
        %metodo di inizializzazione delle memorie della classe
        function obj = initialize(obj)

        end
        
        %metodo di starting della classe per avere una unitial al primo
        %istante di controllo
        function obj = starting(obj)
        
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
            un = obj.Kp*error;

            
            % check azione di controllo per la verifica della saturazione
            % in caso affermativo azione di anti-windup
            if (un > obj.UMax) %saturazione positiva
                un = obj.UMax;
            elseif (un < -obj.UMax) %saturazione negativa
                un = -obj.UMax;
            end

            %scrittura variabile di uscita
            u = un;
        end    
    end
end
