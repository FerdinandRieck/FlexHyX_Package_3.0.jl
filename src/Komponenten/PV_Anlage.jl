Base.@kwdef mutable struct iPV_kante
    i::Number = 0.0
    M::Array{Int} = [0]
end

function PV!(dy,UL,UR,iPV,P,G,T_PV)
    Koeff = P
    G_ref=Koeff["G_ref"]; I_sc_stc=Koeff["I_sc_stc"]; I_ph_stc=Koeff["I_ph_stc"]; V_oc_stc=Koeff["V_oc_stc"]; a_sc=Koeff["a_sc"]; Tc_stc=Koeff["Tc_stc"]; eG=Koeff["eG"]; Ns=Koeff["Ns"]; faktor_a=Koeff["faktor_a"]; Rs_pv=Koeff["Rs_pv"]; Rp=Koeff["Rp"]
    U = UR - UL
    I_ph = G/G_ref*(I_ph_stc + a_sc*(T_PV - Tc_stc));
    a = Ns*faktor_a*T_PV;
    I0_ref = I_sc_stc/exp(V_oc_stc/a)
    I0 = I0_ref*(T_PV/Tc_stc)^3*exp(eG/faktor_a*(1/Tc_stc-1/T_PV))
    dy = I_ph - I0*(exp((U+iPV*Rs_pv)/a)-1) - (U+Rs_pv*iPV)/Rp - iPV;
    return dy
end