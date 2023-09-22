using Plots
using DifferentialEquations

#### Primera Parte:
## estimación del orden de convergencia.

"""

    euler(f,tspan,n,u₀[;p=[]])

Resuelve el problema `u̇ =  f(t,u,p)` con dato inicial `u[tspan[1]]=u₀`, en el intervalo `tspan`, usando `n` pasos. Admite de manera opcional un vector de parámetros `p` que se le pasan a la función `f`.
"""
function euler(f,tspan,n,u₀;p=[])
    t = range(start=tspan[1],stop=tspan[2],length=n)
    h = t[2]-t[1]
    k = length(u₀)
    u = zeros(n)
    u[1] = u₀
    for i in 1:n-1       
        u[i+1] = u[i] + h*f(u[i],p,t[i])
    end
    return t,u    
end;



"""

    logistica(u,p,t)

devuelve la ecuación logística evaluada en `u` con parámetros `p=[r,K]`.
"""
function logistica(u,p,t)
    r,K   = p
    du = r*u*(1-u/K)
end
"""

    estimar_orden()

Resuelve la ecuación logística aplicando el método de Euler y estima su orden de convergencia. Recibe un vector `N` con valores (ordenados) para la cantidad de pasos. Para cada `n∈N` calcula el correspondiente paso `h` grafica `log(error)` en función de `log(h)`. El error se calcula en norma infinito, sobre la malla.   
""";
function estimar_orden(N)
    r     = 0.2
    K     = 50_000_000
    u₀    = 10_000_000
    tspan = [0,100]
    U(t)  = K/(1+exp(-r*t)*(K-u₀[1])/u₀[1])
    h     = zeros(length(N))
    error = zeros(length(N))
    plt_sol = plot(legend=:bottom,title="Soluciones")
    for i in 1:length(N)
        n   = N[i]
        t,u = euler(logistica,tspan,n,u₀,p=[r,K])
        error[i] = maximum(abs.(U.(t) .- u))
        h[i]     = t[2]-t[1]
        plot!(plt_sol,t,u,label="n=$n")
    end 
    tplot  = collect(tspan[1]:0.01:tspan[2])
    plot!(plt_sol,tplot,U.(tplot),label="exacta")
    logerr = log.(error)
    logh   = log.(h)
    orden  = (logerr[2:end]-logerr[1:end-1])./(logh[2:end]-logh[1:end-1])
    plt_orden = plot(logh,logerr)
    return orden,plot(plt_sol,plt_orden,layout=(1,2))       
end;



