### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ c8561f88-916c-11ee-19bb-850b3ffa37d8
begin
	using Pkg;
	Pkg.activate("../")
	Pkg.instantiate()
end

# ╔═╡ 6d7e7e0e-e6e4-4fa8-808b-1ec500a4495d
begin
	using Plots
	using BenchmarkTools
	
	include("./TP3.jl")
end

# ╔═╡ 291b3ea8-163e-44d8-85d8-8ec02189206b
md""" 
## Método Explícito 1D
"""

# ╔═╡ 2ed1733a-a4a1-4f5f-9757-20206decd63c
function probar_metodo_explicito_1d()
	n = 75
	ms = [10, 30, 100]
	dt = 1/n
	hs = [1/(m+1) for m in ms]
	alphas = [(1/2) * h^2 / dt for h in hs]
	sols = [
		metodo_explicito(1, n, ms[i], alphas[i]) for i in 1:3
	]

	anim = @animate for i in 1:n
			plot(0:hs[1]:1, sols[1][i, :], ylim=(0, 1), label="Calor en función al espacio 1")
			plot!(0:hs[2]:1, sols[2][i, :], ylim=(0, 1), label="Calor en función al espacio 2")
			plot!(0:hs[3]:1, sols[3][i, :], ylim=(0, 1), label="Calor en función al espacio 3")
		end
	return anim
end

# ╔═╡ 58e315d2-4645-4376-80b7-19d6d2d31517
# ╠═╡ show_logs = false
anim_explicito = probar_metodo_explicito_1d()

# ╔═╡ d30b2b48-7f0c-40f7-8bd0-b908f4d16aed
gif(anim_explicito, "graph_animation_metodo_explicito_1d.gif", fps = 50)

# ╔═╡ 36605cf4-9350-4380-acfd-3e15102097af
function probar_metodo_implicito1d()
	n = 75
	ms = [10, 30, 100]
	dt = 1/n
	hs = [1/(m+1) for m in ms]
	alphas = [(1/2) * h^2 / dt for h in hs]
	sols = [
		metodo_implicito(1, n, ms[i], alphas[i]) for i in 1:3
	]

	anim = @animate for i in 1:n
			plot(0:hs[1]:1, sols[1][i, :], ylim=(0, 1), label="Calor en función al espacio 1")
			plot!(0:hs[2]:1, sols[2][i, :], ylim=(0, 1), label="Calor en función al espacio 2")
			plot!(0:hs[3]:1, sols[3][i, :], ylim=(0, 1), label="Calor en función al espacio 3")
		end

	return anim
end
	

# ╔═╡ c9046b3d-1019-4b99-b3d5-a3aa81df469b
begin
anim_implicito = probar_metodo_implicito1d()
end

# ╔═╡ 793e7a95-f58a-484a-a8a0-974f65d53066
gif(anim_implicito, "graph_animation_metodo_explicito_1d.gif", fps = 50)

# ╔═╡ ecb1e3d2-6d4d-4fb8-9b2d-30ffe6c9e071
md""" ## Prueba de estabilidad"""

# ╔═╡ 8547e827-7fab-492d-b5c2-cd3502e6632d
function prueba_estabilidad(ϵ)
	n = 75
	m = 30
	dt = 1/n
	h = 1/(m+1)
	alpha = (1/2) * h^2 / dt # siempre valen 1/2
	alpha = ϵ * alpha
	sols = [
		metodo_implicito(1, n, m, alpha),
		metodo_explicito(1,n,m,alpha)
	]
	anim = @animate for i in 1:n
		plot(0:h:1, sols[1][i, :], ylim=(0, 1), label="metodo_implicito"),
		plot!(0:h:1, sols[2][i, :], ylim=(0, 1), label="metodo_explicito")
	end
end

# ╔═╡ 98eed8e8-4631-4f8b-a335-7d1ccd4873e1
# Elegimos epsilon = 1.04 pero para valores mas grandes que 1 se vuelve inestable
gif(prueba_estabilidad(1.04), "graph_animation_metodo_implicito_1d.gif", fps = 50)

# ╔═╡ b025bd94-b97e-4950-a51e-b86efd4067c1
md"""
## Comparación de tiempos de ejecución para la resolución de la ecuación de calor en 2D 
"""

# ╔═╡ b258f0ca-036a-4013-867c-820936878fc5
function comparar_tiempos_ejecucion_ecuacion_calor()
	steps_x = 20
	steps_y = 20
	n = 20
	dt = 1/n
	alpha = (1/2) * ((1/steps_x)^2 + (1/steps_y)^2) / dt
	
	println("Tiempo de ejecución del cálculo de solucion utilizando una matriz rala, y precalculando descomposición LU")
	ex_time, _ = @btime metodo_implicito_2d(1, $steps_x, $steps_y, $n, $alpha, llena=false, LU=true)
	println(ex_time)

	println("Tiempo de ejecución del cálculo de solucion utilizando una matriz rala, sin precalcular descomposición LU")
	ex_time, _ = @btime metodo_implicito_2d(1, $steps_x, $steps_y, $n, $alpha, llena=false, LU=false)
	println(ex_time)

	println("Tiempo de ejecución del cálculo de solucion utilizando una matriz llena, y precalculando descomposición LU")
	ex_time, _ = @btime metodo_implicito_2d(1, $steps_x, $steps_y, $n, $alpha, llena=true, LU=true)
	println(ex_time)

	println("Tiempo de ejecución del cálculo de solucion utilizando una matriz llena, sin precalcular descomposición LU")
	ex_time, _ = @btime metodo_implicito_2d(1, $steps_x, $steps_y, $n, $alpha, llena=true, LU=false)
	println(ex_time)
	
end

# ╔═╡ 9802ff27-f4a2-4def-a9b2-96881842ef14
comparar_tiempos_ejecucion_ecuacion_calor()

# ╔═╡ 128ea921-46e2-413b-b462-f8539de3ed66
function probar_metodo_implicito_ecuacion_calor_2d()
	steps_x = 80
	steps_y = 100
	n = 150
	dt = 1/n

	# r = 1/2
	alpha = (1/2) * ((1/steps_x)^2 + (1/steps_y)^2) / dt
	
	U = metodo_implicito_2d(1, steps_x, steps_y, n, alpha, llena=false, LU=true)
	anim_2d = @animate for i in 1:n
		heatmap(transpose(U[i, :, :]), clim=(0,2),
			xticks=(1:steps_x, [string(round(j, digits=3)) for j in 0:(1/steps_x-1):1]), 
			yticks=(1:steps_y, [string(round(j, digits=3)) for j in 0:(1/steps_y-1):1])
		)
	end

	return anim_2d
end

# ╔═╡ db108402-c5ce-4b38-be60-3c3a7521fcd0
anim_2d = probar_metodo_implicito_ecuacion_calor_2d()

# ╔═╡ 8f7865b1-e36d-4f4d-9f36-c76b9d4ac3e8
gif(anim_2d, "graph_animation-2d.gif", fps = 20)

# ╔═╡ e3e0b706-4fd8-4782-a15a-7a88ad104070
md"""
## Difusión con transporte
"""

# ╔═╡ 48fa3df0-a8b7-4ef4-b12d-9038a04593f3
function probar_metodo_implicito_difusion_con_transporte_2d()
	steps_space = 80
	n = 100
	dt = 1/n

	# r = 1/2
	alpha = (1/2) * (2/steps_space)^2 / dt
	beta = 2
	
	U = metodo_implicito_problema_transporte_2d(1, steps_space, n, alpha, beta)
	anim_2d = @animate for i in 1:n
		heatmap(transpose(U[i, :, :]), clim=(0,1),
	)
	end

	return anim_2d
end

# ╔═╡ 5c96dbde-891f-452f-a2e3-b39b4ee7fff7
anim_2d_transport = probar_metodo_implicito_difusion_con_transporte_2d()

# ╔═╡ 125ae9ad-5570-451a-a7bf-e6ba75946310
gif(anim_2d_transport, "graph_animation-transport-2d.gif", fps = 10)

# ╔═╡ Cell order:
# ╠═c8561f88-916c-11ee-19bb-850b3ffa37d8
# ╠═6d7e7e0e-e6e4-4fa8-808b-1ec500a4495d
# ╟─291b3ea8-163e-44d8-85d8-8ec02189206b
# ╠═2ed1733a-a4a1-4f5f-9757-20206decd63c
# ╠═58e315d2-4645-4376-80b7-19d6d2d31517
# ╠═d30b2b48-7f0c-40f7-8bd0-b908f4d16aed
# ╠═36605cf4-9350-4380-acfd-3e15102097af
# ╠═c9046b3d-1019-4b99-b3d5-a3aa81df469b
# ╠═793e7a95-f58a-484a-a8a0-974f65d53066
# ╟─ecb1e3d2-6d4d-4fb8-9b2d-30ffe6c9e071
# ╠═8547e827-7fab-492d-b5c2-cd3502e6632d
# ╠═98eed8e8-4631-4f8b-a335-7d1ccd4873e1
# ╟─b025bd94-b97e-4950-a51e-b86efd4067c1
# ╠═b258f0ca-036a-4013-867c-820936878fc5
# ╠═9802ff27-f4a2-4def-a9b2-96881842ef14
# ╠═128ea921-46e2-413b-b462-f8539de3ed66
# ╠═db108402-c5ce-4b38-be60-3c3a7521fcd0
# ╠═8f7865b1-e36d-4f4d-9f36-c76b9d4ac3e8
# ╟─e3e0b706-4fd8-4782-a15a-7a88ad104070
# ╠═48fa3df0-a8b7-4ef4-b12d-9038a04593f3
# ╠═5c96dbde-891f-452f-a2e3-b39b4ee7fff7
# ╠═125ae9ad-5570-451a-a7bf-e6ba75946310
