#-- Parameterfunktionen einfügen
include("Netzwerk/b_kennlinie.jl")
include("Netzwerk/pv.jl")
include("Netzwerk/fcn_leistung.jl")
#--

function solveNetzwerk()
    println("---------------- This is FlexhyX ------------------")
    #-- Netwerk einlesen
    J_cfg = JSON.parsefile("src/flexhyx.cfg")
    now = Dates.now(); jetzt = [Dates.year(now) Dates.month(now) Dates.day(now) Dates.hour(now) Dates.minute(now) 0]
    startzeit = get(J_cfg,"Startzeit",jetzt)
    simdauer = get(J_cfg,"Simulationsdauer",86400)
    println("Startzeit, Simdauer:",startzeit," ",simdauer)
    rtol = get(J_cfg,"RTOL",5.0e-4); atol = get(J_cfg,"ATOL",5.0e-4)
    println("rtol,atol:",rtol," ",atol)
    pfad = get(J_cfg,"Pfad","."); pfad="src/"*pfad*"/";
    netzfile = pfad*get(J_cfg,"Netzwerkfile",0)
    eventfile, knoten, kanten = read_netz(pfad,netzfile)
    if isempty(eventfile)
        n_events = 0
    else
        include(eventfile)
    end
    println("N_Events:",n_events)

    #-- Anfangswerte setzen
    IM, IP = inzidenz(knoten,kanten)
    n_n = size(knoten)[1]; n_e = size(kanten)[1];  n_zusatz = 0;
    for i = 1:n_e
        typ = kanten[i]["Typ"]
        if (typ=="iB") n_zusatz = n_zusatz+2 end
    end

    neq = n_n + n_e + n_zusatz;
    println("neq:",neq)
    y = zeros(neq).+NaN;  M = Int[];
    y_typ = Array{String,1}(undef,neq);
    y_kanten = Array{Any}(undef, n_e); y_knoten =  Array{Any}(undef, n_n); # NEU

    U_max = 0;
    for i=1:n_n  #- Knoten ----------------------------
        kk = knoten[i];  typ = kk["Typ"]; y_typ[i] = typ;
        if typ=="U0"
            U0 = knoten[i]["Spannung"]; y_knoten[i] = U_Knoten(U = U0) #NEU
            U_max = max(U_max,U0)
        end
        if typ=="U" #NEU
            y_knoten[i] = U_Knoten()
        end
        M = [M; y_knoten[i].M]
    end
    k = n_n; 
    for i=1:n_e  #- Kanten ----------------------------
        k = k+1; 
        kk = kanten[i]; typ = kk["Typ"];
        y_typ[k] = typ;
        if typ=="iB"
            Koeff = kk["fcn"]()
            q0 = kk["SOC"]*Koeff["Q_max"];
            U0 = Koeff["U0"]
            U_max = max(U_max,U0);
            k = k+1;  #-- Kondensator #NEU (y[k] = 0 gelöscht)
            k = k+1; #-- Ladung #NEU (y[k] = 0 gelöscht)
            y_kanten[i] = iB_kante(q=q0) #NEU
        end
        if typ=="iPV" #NEU
            y_kanten[i] = iPV_kante()
        end
        if typ=="iV" #NEU
            y_kanten[i] = iV_kante()
        end
        M = [M; y_kanten[i].M]
    end

    for i=1:n_n #--- AW ändern ----
        typ = y_typ[i];
        if typ=="U" y_knoten[i].U = U_max; end #NEU
    end
    M = diagm(M) #NEU

    #-- Erzeuge Zustandsvektor y und Indizes wo was steht in y #NEU
    y_elemente = (kanten=y_kanten,knoten=y_knoten)  #-- gesamtes Netzwerk #NEU
    y, idx_Ukn, idx_Pkn, idx_Tkn, idx_ifluss, idx_mfluss, idx_efluss, = tuple2array(y_elemente)


    #---------!!!!z.B. fL2y oben Löschen!!!!
    n_kanten = length(y_kanten); n_knoten = length(y_knoten)

    #-- Netzinfo und Speicherplatz (übergebe als Parameter an solver/dgl-function)
    i_fluss = Array{Number}(undef, n_kanten); #-- nur einmal Speicher reservieren
    m_fluss = Array{Number}(undef, n_kanten); e_fluss = Array{Number}(undef, n_kanten);

    U_L = Array{Number}(undef, n_kanten); U_R = Array{Number}(undef, n_kanten) #-- Eingang, Ausgang der Kante, analog P_L, T_L..

    U_kn = Array{Number}(undef, n_knoten) #-- Knotenpotentiale
    P_kn = Array{Number}(undef, n_knoten); T_kn = Array{Number}(undef, n_knoten) #-- Druck, Temp
    #----------

    #params_alt = IM, IP, fL2y, fR2y, y_typ, y2ele, knoten, kanten, y2Nr, test
    params_neu = y_elemente, i_fluss, m_fluss, e_fluss, idx_ifluss, idx_mfluss, idx_efluss, U_kn, P_kn, T_kn, idx_Ukn, idx_Pkn, idx_Tkn, U_L , U_R, IP, IM
    params = IM, IP, y_typ, knoten, kanten, y_elemente, i_fluss, m_fluss, e_fluss, idx_ifluss, idx_mfluss, idx_efluss, U_kn, P_kn, T_kn, idx_Ukn, idx_Pkn, idx_Tkn, U_L, U_R

    #--------------
    ind_alg = findall(x->x==0,M[diagind(M)]);
    dy = 0*y;
    dgl!(dy,y,params,0.0);
    println("Test Vorher:",Base.maximum(abs.(dy[ind_alg])))
    y_alg = copy(y[ind_alg])
    g!(dy_alg,y_alg) = f_aw!(dy_alg,y_alg,ind_alg,y,params)
    res = nlsolve(g!,y_alg)
    println("AW:",res.zero)
    y[ind_alg] = res.zero;
    dgl!(dy,y,params,0.0);
    println("Test Nachher:",Base.maximum(abs.(dy[ind_alg])))

    #--------------
    t0 = time()
    f = ODEFunction(dgl!,mass_matrix=M)
    tspan = (0.0,simdauer)
    prob_ode = ODEProblem(f,y,tspan,params)
    sol = solve(prob_ode,Rodas4P2(autodiff=false,diff_type=Val{:forward}),progress=true, reltol=rtol,abstol=atol,dtmax=600)
    t1 = time()-t0
    println("CPU:",t1)
    println(sol.retcode," nt=",size(sol.t)); 
    println(sol.destats)
    return sol
    println("---------------- This was FlexHyX -----------------")
end
