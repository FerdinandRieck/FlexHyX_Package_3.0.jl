
#-- Kanten Struct
Base.@kwdef mutable struct m_kante
    m::Number = 0.0
    e::Number = 0.0
end

#-- Knoten Struct
Base.@kwdef mutable struct U_Knoten
    U::Number = 0.0
    M::Array{Int} = [0]
end
Base.@kwdef mutable struct G_Knoten
    P::Number = 200.0
    T::Number = 300.0
end


function tuple2array(y_tuple)
    y_arr = Float64[]; k = 0
    idx_ifluss = Array{Int}(undef, 0,2); idx_mfluss = Array{Int}(undef, 0,2); idx_efluss = Array{Int}(undef, 0,2);  
    idx_Ukn = Array{Int}(undef, 0,2); idx_Pkn = Array{Int}(undef, 0,2); idx_Tkn = Array{Int}(undef, 0,2)
    i_k = 0;
    for y in y_tuple.knoten
        i_k +=1
        for ff in fieldnames(typeof(y))
            if string(ff)!="M"  #NEU
                append!(y_arr,getfield(y,ff)); k +=1
                if string(ff)=="U" idx_Ukn = [idx_Ukn;[i_k k]]; end  #-- Strom von Knoten i_k steht in y an Stelle k
                if string(ff)=="P" idx_Pkn = [idx_Pkn;[i_k k]]; end  
                if string(ff)=="T" idx_Tkn = [idx_Tkn;[i_k k]]; end  
            end
        end
    end
    i_k = 0;
    for y in y_tuple.kanten
        i_k +=1
        for ff in fieldnames(typeof(y))
            if string(ff)!="M"  #NEU
                append!(y_arr,getfield(y,ff)); k +=1
                if string(ff)=="i" idx_ifluss = [idx_ifluss;[i_k k]]; end  #-- Strom der Kante i_k steht in y an Stelle k
                if string(ff)=="m" idx_mfluss = [idx_mfluss;[i_k k]]; end  
                if string(ff)=="e" idx_efluss = [idx_efluss;[i_k k]]; end  
            end
        end
    end
    return y_arr, idx_Ukn, idx_Pkn, idx_Tkn, idx_ifluss, idx_mfluss, idx_efluss
end

function array2tuple!(y_tuple,y_arr)
    idx = 0
    for y in y_tuple.knoten
        for ff in fieldnames(typeof(y))
            if string(ff)!="M" #NEU
                idx += 1
                setfield!(y, ff, y_arr[idx])
            end
        end
    end
    for y in y_tuple.kanten
        for ff in fieldnames(typeof(y))
            if string(ff)!="M" #NEU
                idx += 1
                setfield!(y, ff, y_arr[idx])
            end
         end
    end
    nothing
end