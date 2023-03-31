function fcn_leistung(t)
 A = max(20.0,20.0+10*(t-8*3600)/(8*3600));
 P = 0.0+A*sin(t*2*pi/(4*3600))
# P = ifxaorb(P,P,0.0)
# P = maximum1(P,0.0)
 P = max(P,0.0)
# P=sqrt(P)
end
