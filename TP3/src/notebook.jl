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
## Utils
"""

# ╔═╡ 2ed1733a-a4a1-4f5f-9757-20206decd63c
function probar_metodo_explicito_1d()
	n = 50
	ms = [10, 30, 60]
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
anim = probar_metodo_explicito_1d()

# ╔═╡ d30b2b48-7f0c-40f7-8bd0-b908f4d16aed
gif(anim, "graph_animation_metodo_explicito_1d.gif", fps = 50)

# ╔═╡ cc8ea44b-60aa-4e3b-80f0-9e161f77923a
begin
	steps_x = 100
	steps_y = 50
	dt_2 = 0.05
	alpha_2 = (1/2) * ((1/steps_x)^2 + (1/steps_y)^2) / dt
end

# ╔═╡ 1ca37473-919c-4be5-bbde-abe6b79ab3fd
begin
	U_2d_filled_matrix = metodo_implicito_2d(1, steps_x, steps_y, dt_2, alpha_2, false, true)
end

# ╔═╡ 0cc505a1-832b-40b8-b9a2-2039c080a1d1
begin
	n, m_x, m_y = size(U_2d_filled_matrix)
	anim_2d = @animate for i in 1:n
		heatmap(transpose(U_2d_filled_matrix[i, :, :]), clim=(0,2),
			xticks=(1:m_x, [string(round(j, digits=3)) for j in 0:(1/m_x-1):1]), 
			yticks=(1:m_y, [string(round(j, digits=3)) for j in 0:(1/m_y-1):1])
		)
	end
end

# ╔═╡ 8f7865b1-e36d-4f4d-9f36-c76b9d4ac3e8
gif(anim_2d, "graph_animation-2d.gif", fps = 2)

# ╔═╡ 77c94803-2216-4019-9e87-fcdecd018d17
U_2d_transport_matrix = metodo_implicito_problema_transporte_2d(1, 300, 0.05, 0.01, 1.3)

# ╔═╡ 18576797-130d-4fe4-8ef0-34aab35dba8f
begin
	n_transport, m_transport, _ = size(U_2d_transport_matrix)
	anim_2d_transform = @animate for i in 1:n_transport
		heatmap(transpose(U_2d_transport_matrix[i, :, :]), clim=(0,2),
		xticks=(0:(m_transport+1)/4:1, [string(j) for j in 0:(m_transport+1)/4:1])
	)
	end
end

# ╔═╡ 125ae9ad-5570-451a-a7bf-e6ba75946310
gif(anim_2d_transform, "graph_animation-2d.gif", fps = 2)

# ╔═╡ c2a9b415-3d34-4973-9b6c-4b4d98ee32f5
?heatmap

# ╔═╡ Cell order:
# ╠═c8561f88-916c-11ee-19bb-850b3ffa37d8
# ╠═6d7e7e0e-e6e4-4fa8-808b-1ec500a4495d
# ╟─291b3ea8-163e-44d8-85d8-8ec02189206b
# ╠═2ed1733a-a4a1-4f5f-9757-20206decd63c
# ╠═58e315d2-4645-4376-80b7-19d6d2d31517
# ╠═d30b2b48-7f0c-40f7-8bd0-b908f4d16aed
# ╠═cc8ea44b-60aa-4e3b-80f0-9e161f77923a
# ╠═1ca37473-919c-4be5-bbde-abe6b79ab3fd
# ╠═0cc505a1-832b-40b8-b9a2-2039c080a1d1
# ╠═8f7865b1-e36d-4f4d-9f36-c76b9d4ac3e8
# ╠═77c94803-2216-4019-9e87-fcdecd018d17
# ╠═18576797-130d-4fe4-8ef0-34aab35dba8f
# ╠═125ae9ad-5570-451a-a7bf-e6ba75946310
# ╠═c2a9b415-3d34-4973-9b6c-4b4d98ee32f5
