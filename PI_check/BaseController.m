classdef BaseController < handle
    % le proprietà (o i membri) sono variabili persistenti dell'oggetto
    properties  (Access = protected)
        st % tempo di campionamento
        umax % massima azione di controllo
    end

    methods
        % il costruttore crea l'oggeto BaseControllore e lo inizializza
        function obj=BaseController(st)
            obj.st=st;
        end

        % chiamo questa funzione quando devo (re)inizializzare il
        % controllore
        function obj=inizialize(obj)
        end

        % chiamo questa funzione quando avviare il controllore. Viene
        % chiama una volta e permette di implementare la commutazione
        % bumpless (riparto da dove mi ero fermato)
        %
        % reference = setpoint 
        % y = uscita
        % u = azione di controllo
        function obj=starting(obj,reference,y,u)
        end

        % chiamo questa funzione quando stoppare il controllore (di norma
        % nel corso non dovrebbe essere necessaria)
        function obj=stopping(obj,reference,y)
        end
        
        % setta l'azione di controllo massima
        function setUMax(obj,umax)
            obj.umax=umax;
        end

        % calcola l'azione di controllo. viene chiamata ogni ciclo
        %
        % reference = setpoint
        % y = uscita
        % u = azione di controllo
        function u=computeControlAction(obj,reference,y)
            u=0*obj.umax;
        end

        % restituisce il tempo di campionamento
        function st=getSamplingPeriod(obj)
            st=obj.st;
        end
    end
end