classdef ControlledSystem < handle
    % questa classe permette di simulare il sistema e il controllore
    properties  (Access = protected)
        model
        controller
        time
        st
        controlled_output_index
        goal_output=1;
        timer
        realtime=false; % se vero, simula un secondo in (almeno) un secondo
    end
    methods  (Access = public)
        % costruisco la classe fornendo il modello da simulare
        function obj=ControlledSystem(model)
            obj.model=model;
            obj.controller=[];
            obj.time=0;
            obj.timer=tic;
            obj.st=model.getSamplingPeriod;
        end

        % setto il controllore. Il controllore può lavorare su un numero
        % limitato di uscite, o può riceverle tutte (default)
        function setController(obj,controller,controlled_output_index)
            if nargin<3
                obj.controlled_output_index=1:obj.model.getOutputNumber;
            else
                obj.controlled_output_index=controlled_output_index;
            end
            obj.controller=controller;
            assert(obj.controller.getSamplingPeriod==obj.model.getSamplingPeriod,'Controller sampling period is wrong');
            obj.controller.setUMax(obj.model.getUMax)
        end

        % inizializzo una nuova simulazione
        function initialize(obj)
            rng shuffle % genero un nuovo seed random
            obj.model.initialize;
            if ~isempty(obj.controller)
                obj.controller.inizialize;
            end
            obj.time=0;
            obj.timer=tic;
        end

        % openloop permette di simulare il sistema in anello aperto
        function [y,t]=openloop(obj,control_action)
            
            obj.model.setScenario(1);
            t=obj.time;
            obj.time=obj.time+obj.st;
            y=obj.model.computeOutput;
            obj.model.updateState(control_action,t);
        end

        % step permette di simulare il sistema in anello chiuso
        function [y,u,t]=step(obj,reference,u_feedforward)
            if (nargin<3)
                u_feedforward=zeros(obj.model.getInputNumber,1);
            end
            t=obj.time;
            obj.time=obj.time+obj.st;
            y=obj.model.computeOutput;
            assert(~isempty(obj.controller),'Controller is not set');
            u=obj.controller.computeControlAction(reference,y(obj.controlled_output_index))+u_feedforward;
            obj.model.updateState(u,t);
            
            if obj.realtime
                dtime=obj.time-toc(obj.timer);
                pause(dtime)
            end
        end

        function st=getSamplingPeriod(obj)
            st=obj.st;
        end

        % lancia la validazione del controllore
        function [score,results]=evalution(obj)
            for is=1:5
                results(is)=simulation(obj,is+1); %#ok<AGROW> 
                scores(is)=obj.computeScore(results(is)); %#ok<AGROW> 
            end
            score=mean(scores);
        end

        % simula su uno scenario (funzione usata per calcolare il punteggio, non
        % dovrebbe servirvi)
        function [result]=simulation(obj,scenario)
            obj.initialize
            obj.model.setScenario(scenario);
            [t,reference]=generateTask(obj,scenario);
            y=zeros(length(t),obj.model.getOutputNumber);
            u=zeros(length(t),obj.model.getInputNumber);
            for idx=1:length(t)
                [y(idx,:),u(idx,:),t(idx,1)]=obj.step(reference(idx,:));
            end

            result.t=t;
            result.y=y;
            result.u=u;
            result.reference=reference;

            
        end

        % genera un task (funzione usata per calcolare il punteggio, non
        % dovrebbe servirvi)
        function [t,reference]=generateTask(obj,scenario)
            t=(0:obj.st:20)';
            reference=zeros(length(t),obj.model.getOutputNumber);
        end
    end

    methods  (Access = protected)

        % calcola lo score (funzione usata per calcolare il punteggio, non
        % dovrebbe servirvi)
        function score=computeScore(obj,result)
            score=0;
        end
    end

end
