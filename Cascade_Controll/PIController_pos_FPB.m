classdef PIController_pos_FPB < BaseController

    properties (Access = private)
        %pi parameters
        Kp %valore di azione proporzionale
        Ki %valore di azione integrale
        u_past %valore dell'azione di controllo nell'istante precedente
        e_past %valore dell'errore passato
        Ti
        UMax
       

        %filter parameters
        Tf       %tau del filtro
        UinPast  %valori precedenti in ingresso al filtro
        UoutPast %valori prededenti del filtro in uscita
        Fs %filtro in continua
        Fd %filtro in discreto
        A  %vettore parametri per discretizzazione rispetto a y
        B  %vettore parametri per discretizzazione rispetto a u


        j   % costanti filtro passa basso
        k
        l
        m

        u_m1    % buffer di memoria per filtro
        un_m1


    end


    methods
        %metodo per la creazione del controllore PI
        function obj = PIController_pos_FPB(st,Kp,Ki,Tf)
            %check input
            assert(isscalar(Kp));
            assert(Kp>0);
            assert(isscalar(Ki));
            assert(Ki>0);
            assert(isscalar(Tf));
            assert(Tf>=0);
            assert(isscalar(st));
            assert(st>0);
            %-----------
            obj@BaseController(st)
            obj.Kp=Kp;
            obj.Ki=Ki;
            obj.Ti=double(Kp/Ki);
            obj.Tf = Tf;
            Discretization(obj);

        end

        %inizializzazione dei valori passati
        function obj = initialize(obj)
            obj.u_past = 0;
            obj.e_past = 0;
            obj.u_m1 = 0;
            obj.un_m1 = 0;
            obj.UinPast=0;
            obj.UoutPast=0;
        end

        %funzione per return di Ki
        function out = valKi(obj)
            out = obj.Ki;
        end
        function out = val_U_pi(obj)
            out = obj.u;
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
        
        function obj = SetUmax(obj,umax)
            assert(isscalar(umax));
            assert(umax>0);
            obj.UMax=umax;
        end


        function obj = Discretization(obj)
            Fpb = tf(1,[obj.Tf 1]);
            Fpb_disc = c2d(Fpb,obj.st,'tustin');
            num_fpb = Fpb_disc.Numerator{1};
            den_fpb = Fpb_disc.Denominator{1};

            obj.j = num_fpb(1); %z
            obj.k = num_fpb(2); %z-1
            obj.l = den_fpb(1); %z  
            obj.m = den_fpb(2); %z-1
        end

        %funzione per inizializzare i valori del pi di posozione
        function obj = starting(obj,reference,y_feedback,uinitial)
            % verifico correttezza degli ingressi.
            % si richiede che reference,y e u siano scalari
            assert(isscalar(reference));
            assert(isscalar(y_feedback));
            assert(isscalar(uinitial));

            % inizializzo l'azione integrale con implementazione bumbless
            error = double(reference-y_feedback);
            obj.u_m1 = 0;
            u_now = double((uinitial*obj.l)/obj.j-obj.Kp.*((1+(obj.st/obj.Ti))*error));  %solo pi

            obj.un_m1 = 0;
            obj.u_past = double(u_now);
            obj.e_past = double(0);
        end

        %funzione per il calcolo della azione di controllo del controllore`
        %implementato con il metodo di implementazione digitale mediante
        %l'utilizzo dell'algoritmo di velocità.
        function u = computeControlAction(obj,reference,y_feedabck)
            assert(isscalar(reference));
            assert(isscalar(y_feedabck));
            error = double(reference-y_feedabck);
            %FORMULA ALGORITMO DI  VELOCITA'

            u_now = double(obj.u_past+obj.Kp.*((1+(obj.st/obj.Ti))*error-obj.e_past));

            un = (obj.j*u_now + obj.k*obj.u_m1 - obj.m*obj.un_m1)/obj.l;

            if (abs(un)>obj.UMax)
                if un > 0
                    un = double(obj.UMax);
                else
                    un = double(-obj.UMax);
                end
            end

            obj.u_m1 = double(u_now);
            obj.un_m1 = double(un);
            obj.e_past = double(error);
            obj.u_past = double(u_now);
            u = double(un);
        end
    end
end