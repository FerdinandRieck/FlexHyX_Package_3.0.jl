function pv()
#--  PV-Anlage Konstanten
 koeff = Dict("dummy"=>1.0);
 koeff["G_ref"] = 1000;
 koeff["I_sc_stc"] = 3.11; koeff["I_ph_stc"] = koeff["I_sc_stc"];
 koeff["V_oc_stc"] = 21.8; koeff["Vmpp_stc"] = 17 ; koeff["Impp_stc"] = 2.88;
 koeff["a_sc"] = 0.0013; koeff["Tc_stc"] = 298;
 koeff["eG"] = 1.12; #-- band energy gap in eV fuer Si
 koeff["Ns"] = 36; #--Anzahl
 A_pv = 1.15;
 k_pv = 1.3805*1.0e-23; #-- Boltzmann - Konstante
 q = 1.6021*1.0e-19;
 koeff["faktor_a"] = A_pv*k_pv/q;
 koeff["Rs_pv"] = 0.45;  #-- m�ssen nochmal noch berechnet werden
 koeff["Rp"] = 310.0248;
 return koeff
#--
end
