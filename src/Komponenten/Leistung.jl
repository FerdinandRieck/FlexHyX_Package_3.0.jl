Base.@kwdef mutable struct iV_kante
    i::Number = 0.0
    M::Array{Int} = [0]
end

function verbraucher_alt(t)
    P = 10*max(sin(2*pi/3600*t),0);
end

function verbraucher(t)
    ts = range(3600.0,36000.0,step = 3600.0) 
    return 50.0*einaus(t,ts,10.0)
end