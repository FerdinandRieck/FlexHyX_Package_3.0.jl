function read_netz(pfad,netzfile)
	typ_kn = ["U","U0"]
	typ_ka = ["iB","iV","iPV"]
	J = JSON.parsefile(netzfile)
	eventfile = []
	if haskey(J,"Events")
		eventfile = get(J,"Events",[]); eventfile = pfad*eventfile[2:end]*".jl"
		println("Eventfile:",eventfile)
	end
    knoten = [];  kanten = []
	K = get(J,"Knoten",0)
    for kk in K
		if haskey(kk,"#")==false
     	    typ = kk["Typ"]; iart = 0;
            if (typ=="U0") & (haskey(kk,"Spannung")==false) kk["Spannung"] = 0; end
            iart = findall(x->x==typ,typ_kn)[1];  kk["iart"] = -iart
		    push!(knoten,kk);
        end
    end
	K = get(J,"Kanten",0)
	for kk in K
		if haskey(kk,"#")==false
			typ = kk["Typ"]; iart = 0;
			if (typ=="iPV") kk["Temp"] = kk["Temp"] + 273.15; end
			if (typ=="iV")&(haskey(kk,"R")==false) kk["R"]=0.0; end 
			#if (typ=="iB") end
				iart = findall(x->x==typ,typ_ka)[1];  kk["iart"] = iart
				for (k, v) in kk
					if v[1]=='@'
						fcn = v[2:end];
						#file = pfad*fcn*".jl";
						file = "Netzwerk/"*fcn*".jl";
						println(file);   include(file)
						kk[k] = getfield(Main, Symbol(fcn))
					end
				end
			push!(kanten,kk);
	   end
	end
#-- Zweiter Durchlauf: Von/Nach = aktualisieren, RefKante aktualisieren
	n_n = size(knoten)[1];   n_e = size(kanten)[1]
	nr2kn = zeros(Int,n_n); nr2ka = zeros(Int,n_e)
	for i = 1:n_n
		nr2kn[i] = knoten[i]["Nr"];
	end
	for i = 1:n_e
		nr2ka[i] = kanten[i]["Nr"];
	end
	for i = 1:n_e
		if haskey(kanten[i],"RefKante")
			i_ka = findall(x->x==kanten[i]["RefKante"],nr2ka)[1];
			kanten[i]["RefKante"] = i_ka;
		end
		kanten[i]["VonNach"][1] = findall(x->x==kanten[i]["VonNach"][1],nr2kn)[1];
		kanten[i]["VonNach"][2] = findall(x->x==kanten[i]["VonNach"][2],nr2kn)[1];
	end
#--
    return eventfile, knoten, kanten
end