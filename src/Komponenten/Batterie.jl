Base.@kwdef mutable struct iB_kante
    i::Number = 0.0
    u::Number = 0.0
    q::Number = 0.0
    M::Array{Int} = [0; 1; 1] 
end

function Batterie!(dy,UL,UR,iB,P,U_E,Q)
    Koeff = P
    A=Koeff["A"]; B=Koeff["B"]; K1=Koeff["K1"]; K2=Koeff["K2"]; Q_max=Koeff["Q_max"]; R=Koeff["R"]; U0=Koeff["U0"]; soc_min=Koeff["soc_min"]; 
    U_E = min(A,max(U_E,0))
    soc = Q/Q_max; soc = minimum1(maximum1(soc,soc_min),1.095);
    U_B = U0 + U_E - K1*ifxaorb(iB,1.0/soc,1.0/(1.1-soc))*iB - K2*(Q_max-Q)/soc;
    dy[1] = U_B - R*iB - (UR-UL);  #-- Bat.spannung
    dy[2] = iB*B*(ifxaorb(iB,-U_E,U_E-A))
    dy[3] = -iB
    return dy
end



