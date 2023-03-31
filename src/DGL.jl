function dgl!(dy,y,P,t) 
    IM, IP, y_typ, knoten, kanten, y_elemente, i_fluss, m_fluss, e_fluss, idx_ifluss, idx_mfluss, idx_efluss, U_kn, P_kn, T_kn, idx_Ukn, idx_Pkn, idx_Tkn, U_L, U_R = P
    #-- Innerhalb von dgl-Funktion: alle benötigten Infos, Speicherplatz aus parameter vorhanden
    array2tuple!(y_elemente,y)

    i_fluss .= 0.0; i_fluss[idx_ifluss[:,1]] = y[idx_ifluss[:,2]]  #-- Flussvektor Strom
    m_fluss .= 0.0; m_fluss[idx_mfluss[:,1]] = y[idx_mfluss[:,2]]  #-- Flussvektor Massenstrom
    e_fluss .= 0.0; e_fluss[idx_efluss[:,1]] = y[idx_efluss[:,2]]  #-- Flussvektor Energie
    
    sum_i = IP*i_fluss - IM*i_fluss   #-- Beispiel Knotenbilanzen für Strom, ggf. Speicher für sum_i vorher reservieren !!  
    
    U_kn .= 0.0; U_kn[idx_Ukn[:,1]] = y[idx_Ukn[:,2]]  #-- Knotenpotentiale
    P_kn .= 0.0; P_kn[idx_Pkn[:,1]] = y[idx_Pkn[:,2]]  #-- Knotendrücke
    T_kn .= 0.0; T_kn[idx_Tkn[:,1]] = y[idx_Tkn[:,2]]  #-- Knotentemp
    
    U_L = IM'*U_kn; U_R = IP'*U_kn; #-- Beispiel für Kanteneingänge, -ausgänge, analog T_L, P_L,..
    #-- jetzt alle Knoten und Kanten druchlaufen und Gleichungen erzeugen
    
    n_n = size(IM)[1]; n_e = size(IM)[2];
    t_scale = minimum1(t/60,1.0);
    for k = 1:n_n #-- Knotengleichungen
        typ = y_typ[k]; kk = knoten[k]; dy[k] = sum_i[k] 
        if typ=="U0" dy[k] = y[k] - kk["Spannung"]; end
    end
    k = n_n;
    for i=1:n_e  #-- Kanten
        k = k+1; typ = y_typ[k];
        kk = kanten[i];
        io = 1.0;
        if get(kk,"Schaltzeit",0)!=0
            io = einaus(t,kk["Schaltzeit"],60.0);
        end
        if kk["Typ"]=="iV" #-- Verbraucher
            if isa(kk["Leistung"],Number)  L = kk["Leistung"]; end
            if isa(kk["Leistung"],Function)  L = kk["Leistung"](t); end
            iV = y_elemente.kanten[i].i
            P = L*t_scale;
            dy[k] = P/(U_L[i]-U_R[i]) - iV;
        end
        if kk["Typ"]=="iPV" #-- PV Anlage
            G = kk["Strahlung"]; T_PV = kk["Temp"]; 
            Koeff = kk["fcn"]();
            iPV = y_elemente.kanten[i].i
            dy[k] = PV!(dy[k],U_L[i],U_R[i],iPV,Koeff,G,T_PV)
        end
        if kk["Typ"]=="iB" #-- Batterie
            Koeff = kk["fcn"]()
            iB = y_elemente.kanten[i].i
            Q = y_elemente.kanten[i].q; 
            U_E = y_elemente.kanten[i].u;
            dy[k:k+2] = Batterie!(dy[k:k+2],U_L[i],U_R[i],iB,Koeff,U_E,Q)
            k = k+2; 
        end
    end
end

function f_aw!(dy_alg,y_alg,ind_alg,y,P)
    dy = 0*y
    y[ind_alg] = y_alg;
    dgl!(dy,y,P,0.0)
    for i=1:length(y_alg) #-- keine Ahnung, warum das nicht mit dy_alg=dy[ind_alg] funktioniert
        dy_alg[i] = dy[ind_alg[i]];
    end
end