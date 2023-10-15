#using Pkg
# Agregando las bibliotecas necesarias
# Pkg.add("DataFrames")
# Pkg.add("CSV")
# Pkg.add("Plots")
# Pkg.add("DifferentialEquations")
# # Pkg.add("Optimization") # No hay un paquete directo con el nombre "Optimization", podría ser "JuMP" o "Optim" que son comúnmente utilizados.
# Pkg.add("DiffEqParamEstim")
# # Pkg.add("OptimizationOptimJL") # No reconozco este paquete, verifica el nombre.
# Pkg.add("Dates")
# Pkg.add("PlutoUI")
# Pkg.add("TimeSeries")
# Pkg.add("Interpolations")
# Pkg.add("Random")
# Pkg.add("Optimization")
# Pkg.add("OptimizationOptimJL")

##CSV.write("primeraOla.csv",  DataFrame(weeklyNewCasesFirstWave))
# begin
# df = DataFrame(Column1 = weeklyNewCasesFirstWave)
# CSV.write("primeraOla.csv", df)
# end	


using DataFrames, CSV, Plots, DifferentialEquations, Optimization, DiffEqParamEstim,OptimizationOptimJL,Dates, PlutoUI, TimeSeries, Interpolations, Random
global_random_seed = 1234;
df = CSV.read("./primeraOla.csv", DataFrame);
data = df[!,:Column1]

start1 = 1
end1 = 41



function rand1(leftB,rightB)
    return leftB + (rightB - leftB)*rand()
end


## Modelos

function SIR!(du,u,p,t)
    β,σ = p
	S, I, R = u
    du[1] = -β * S * I
    du[2] = β * S * I - σ * I
    du[3] = σ * I
end

function SEIR!(du,u,p,t)
    β,σ,γ = p
	S, E, I, R = u
    du[1] = -β*S*I
    du[2] = β*S*I - γ * E
    du[3] = γ*E-σ*I
    du[4] = σ*I
end

function SEIRS!(du,u,p,t)
    β,σ,γ,δ = p
	S, E, I, R = u
    du[1] = -β*S*I + δ*R
    du[2] = β*S*I -γ*E
    du[3] = γ*E-σ*I
    du[4] = σ*I - δ*R
end



# Costo 
function costo(solution, tspan, datos, modelo)
	"""
	solution: Solucion a un ODEProblem
	tiempo: Vector de tiempos
	datos: Datos correspondientes al vector de tiempos indicados. Deben representar I
	modelo: Representa el modelo a ajustar la cantidad de infectados
	"""
	if any((!SciMLBase.successful_retcode(s.retcode) for s in solution))
        return Inf
	end
		
	if (modelo == "sir")
		β = solution.prob.p[1]
		S = solution.(tspan[1]:tspan[2], idxs=1)
		I = solution.(tspan[1]:tspan[2], idxs=2)
		predicted_data = β * S .* I 
	    loss = sum((predicted_data - datos).^2)

		return loss 
		
	elseif (modelo == "seir")
		γ = solution.prob.p[3]
		E = solution.(tspan[1]:tspan[2], idxs=2)
		predicted_data = γ * E
	    loss = sum((predicted_data - datos).^2)

		return loss 

	elseif (modelo == "seirs")
		γ = solution.prob.p[3]
		E = solution.(tspan[1]:tspan[2], idxs=2)
		predicted_data = γ * E
	    loss = sum((predicted_data - datos).^2)

		return loss

	# Modelos para la segunda parte
	elseif (modelo == "subregistro")
		γ = solution.prob.p[3]
		α = solution.prob.p[4]
		E = solution.(tspan[1]:tspan[2], idxs=2)

		predicted_data = α * γ * E
	    loss = sum((predicted_data - datos).^2)

		return loss
	end
end
	


function Search(maxIters,modelo)
    if (modelo == "sir")
        # Inicialización de las variables que almacenarán los mejores parámetros y valor de f.
        best_params = (0, 0, 0,0)
        best_value = Inf  
        # me genero los valores aleatorios
        for _ in 1:maxIters
        # p1U = rand1(0.99,1) # en el [0,1)
            p2U = rand1(0,15)
            p3U = rand1(0,15)
        # p1L = rand1(0,p1U)
            p2L = rand1(0,p2U)
            p3L = rand1(0,p3U)
            params_ini = [0.9999,p2U,p3U] # pongo lower bounds, no quiero que sea 0
            sir_prob     = ODEProblem(SIR!, [params_ini[1], 1-params_ini[1], 0],(start1, end1), params_ini[2:3])
            sir_func     = build_loss_objective(
            sir_prob, AutoTsit5(Rosenbrock23()),
            sol->costo(sol, (start1, end1), data, "sir"), Optimization.AutoFiniteDiff(),
            prob_generator = (prob,q)->remake(
                prob,
                u0=[
                    q[1],
                    1-q[1],
                    0.
                ],p=q[2:3]
            )
            )
            optprob = OptimizationProblem(sir_func, params_ini, lb=[0.9999,p2L,p3L], ub=[1, p2U, p3U])
            params  = solve(optprob,SAMIN(rt=0.98),maxiters=100000)
            prob_fitted = ODEProblem(SIR!,[params[1],1-params[1],0],(start1, end1), params[2:3],abstol=1e-6,reltol=1e-6)
            sol_fitted = solve(prob_fitted)
            cost = costo(sol_fitted,(start1,end1) , data,"sir")
            if cost < best_value
                best_params = (p2L,p3L,p2U,p3U)
                best_value = cost
            end
        end
        return best_params

    elseif (modelo =="seir")
        best_params = (0,0,0,0,0,0,0,0)
        best_value = Inf
        for _ in 1:maxIters
            p2U = rand1(0,20)
            p3U = rand1(0,30)
            p4U = rand1(0,30)
            p5U = rand1(0,30)
            p2L = rand1(0,p2U)
            p3L = rand1(0,p3U)
            p4L = rand1(0,p4U)
            p5L = rand1(0,p5U)
            params_ini = [0.9999,p2L,p3L,p4L,p5L]
            # S0,ρ,β,σ,γ  = params_ini
            seir_prob     = ODEProblem(
            SEIR!, [params_ini[1], params_ini[2]*(1-params_ini[1]),1-params_ini[1]-params_ini[2]*(1-params_ini[1]), 0.],
            (start1, end1), [params_ini[3],params_ini[4],params_ini[5]])
            seir_func     = build_loss_objective(
                seir_prob,AutoTsit5(Rosenbrock23()),
                sol->costo(sol, (start1, end1), data, "seir"), Optimization.AutoFiniteDiff(),
                prob_generator = (prob, q) -> remake(
                    prob,
                    u0=[
                        q[1],
                        q[2]*(1-q[1]),
                        1-q[1]-q[2]*(1-q[1]), 
                        0.
                    ],
                    p=q[3:5]
                )
            )
            optProb_seir = OptimizationProblem(seir_func, params_ini, lb=[0.9999, p2L, p3L, p4L, p5L],ub=[1,p2U,p3U,p4U,p5U])
            params = solve(optProb_seir,SAMIN(rt=0.98),maxiters=100000)
            prob_fitted = prob_fitted = ODEProblem(SEIR!,[params[1],params[2]*(1-params[1]),1-params[1]-params[2]*(1-params[1]), 0.],
            (start1, end1), params[3:5],abstol=1e-8,reltol=1e-8)
            sol_fitted = solve(prob_fitted)
            cost = costo(sol_fitted,(start1,end1) , data,"seir")
            if cost < best_value
                best_params = (p2L,p3L,p4L,p5L,p2U,p3U,p4U,p5U)
                best_value = cost
            end
        end
        return best_params
        
    elseif (modelo == "seirs")
        best_params = (0,0,0,0,0,0,0,0,0,0)
        best_value = Inf
        for _ in 1:maxIters
            p2U = rand1(0,30)
            p3U = rand1(0,30)
            p4U = rand1(0,30)
            p5U = rand1(0,30)
            p2L = rand1(0,p2U)
            p3L = rand1(0,p3U)
            p4L = rand1(0,p4U)
            p5L = rand1(0,p5U)
            p6U = rand1(0,1)
            p6L = rand1(0,p6U)
            params_ini = [0.9999,p2L,p3L,p4L,p5L,p6L]
            seir_prob     = ODEProblem(SEIRS!,[params_ini[1],params_ini[2]*(1-params_ini[1]),1-params_ini[1]-params_ini[2]*(1-params_ini[1]), 0.],
            (start1, end1), params_ini[3:6],abstol=1e-8,reltol=1e-8)
            seirs_func     = build_loss_objective(
                seir_prob,AutoTsit5(Rosenbrock23()),
                sol->costo(sol, (start1, end1), data, "seirs"), Optimization.AutoFiniteDiff(),
                prob_generator = (prob,q)->remake(
                    prob,
                    u0=[
                        q[1],
                        q[2]*(1-q[1]),
                        1-q[1]-q[2]*(1-q[1]),
                        0.
                    ], p=q[3:6]
                )
            )
            optProb_seir = OptimizationProblem(
                seirs_func, 
                params_ini, 
                lb=[0.9999, p2L, p3L, p4L, p5L, p6L],
                ub=[1,p2U,p3U,p4U,p5U,p6U]
            )
            params = solve(optProb_seir,SAMIN(rt=0.97),maxiters=100000)
            prob_fitted = ODEProblem(SEIRS!,[params[1],params[2]*(1-params[1]),1-params[1]-params[2]*(1-params[1]), 0.],
            (start1, end1), params[3:6],abstol=1e-8,reltol=1e-8)
            sol_fitted = solve(prob_fitted)
            cost = costo(sol_fitted,(start1,end1) , data,"seirs")
            if cost < best_value
                best_params = (p2L,p3L,p4L,p5L,p6L,p2U,p3U,p4U,p5U,p6U)
                best_value = cost
            end
        end
        return best_params
    end  
end


# SIR
        
# el de 10 iteraciones (4.164534396313813, 2.1810522741456335, 14.454645966847115, 13.605459664051772)
# el de 100 iteraciones = (3.9040513343338192, 10.158012714894639, 10.651000318667739, 13.887391830484965)

# SEIR


Random.seed!(global_random_seed)
println(Search(100,"seirs"))



