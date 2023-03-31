function b_kennlinie()
#--  Batterie Konstanten
koeff = Dict("dummy"=>1.0);
koeff["A"] = 0.4919; 
koeff["B"] = 1.302; 
koeff["K1"] = 0.0224; 
koeff["K2"] = 6.222222222222222e-06; 
koeff["Q_max"] = 65880; 
koeff["R"] = 0.5; 
koeff["U0"] = 12.6481; 
koeff["soc_min"] = 0.031392201880530
return koeff
#--
end