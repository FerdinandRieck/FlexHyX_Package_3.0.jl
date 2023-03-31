# Batterie
A = 0.4919; 
B = 1.302; 
K1 = 0.0224; 
K2 = 6.222222222222222e-06; 
Q_max = 65880; 
R = 0.5; 
U0 = 12.6481; 
soc_min = 0.031392201880530

UL=0.0; UR=12.0; iV=0.0; iB=0.0; U_E=0.0; Q = 59292.0 # für Berechnung der AW

# PV_Anlage
G_ref = 1000; 
I_sc_stc = 3.11; I_ph_stc = I_sc_stc; 
V_oc_stc = 21.8; Vmpp_stc = 17.0 ; Impp_stc = 2.88;
a_sc = 0.0013; Tc_stc = 298.0; 
eG = 1.12; # band energy gap in eV für Si
Ns = 36.0; # Anzahl
A_pv = 1.15;
k_pv = 1.3805*1.0e-23; # Boltzmann - Konstante
q = 1.6021*1.0e-19;
faktor_a = A_pv*k_pv/q;
Rs_pv = 0.45;  # müssen nochmal noch berechnet werden
Rp = 310.0248;

iPV = 0.0 # für Berechnung der AW