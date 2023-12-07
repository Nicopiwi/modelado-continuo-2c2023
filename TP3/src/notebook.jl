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
	#using Benchmark
	
	include("./TP3.jl")
end

# ╔═╡ 2ed1733a-a4a1-4f5f-9757-20206decd63c
begin
	h = 0.1
	dt = 0.05
	alpha = (1/2) * h^2 / dt
end

# ╔═╡ d957c5cf-cacf-42d6-8dca-ecd5cb25e42e
U_explicit = metodo_explicito(1, h, dt, alpha)

# ╔═╡ 5e150598-7fe8-4e82-a6d8-b1f833dc4569
begin 
	anim = @animate for u in eachrow(U_explicit)
		plot(u, ylim=(0, 1), label="Calor en función al espacio")
	end
end

# ╔═╡ d30b2b48-7f0c-40f7-8bd0-b908f4d16aed
gif(anim, "graph_animation.gif", fps = 2)

# ╔═╡ cc8ea44b-60aa-4e3b-80f0-9e161f77923a
begin
	steps_x = 10
	steps_y = 5
	dt_2 = 0.05
	alpha_2 = (1/2) * ((1/steps_x)^2 + (1/steps_y)^2) / dt
end

# ╔═╡ 1ca37473-919c-4be5-bbde-abe6b79ab3fd
U_2d_filled_matrix = metodo_implicito_2d(1, steps_x, steps_y, dt_2, alpha_2, false, true)

# ╔═╡ 0cc505a1-832b-40b8-b9a2-2039c080a1d1
begin
	#TODO: Corregir quedaron invertidos el x y el y (viene del source)
	n, m_x, m_y = size(U_2d_filled_matrix)
	println(m_x)
	println(m_y)
	print(length(0:(1/(m_x-1)):1))
	anim_2d = @animate for i in 1:n
		heatmap(U_2d_filled_matrix[i, :, :], clim=(0,2),
			xticks=(1:m_x, [string(round(j, digits=3)) for j in 0:(1/m_x-1):1]), 
			yticks=(1:m_y, [string(round(j, digits=3)) for j in 0:(1/m_y-1):1])
		)
	end
end

# ╔═╡ 8f7865b1-e36d-4f4d-9f36-c76b9d4ac3e8
gif(anim_2d, "graph_animation-2d.gif", fps = 2)

# ╔═╡ 8416006e-b059-4e8a-9dc7-d77ce84c7746
U_2d_filled_matrix[12,:,:]

# ╔═╡ 77c94803-2216-4019-9e87-fcdecd018d17
U_2d_transport_matrix = metodo_implicito_problema_transporte_2d(1, 300, 0.05, 0.01, 1.3)

# ╔═╡ 18576797-130d-4fe4-8ef0-34aab35dba8f
begin
	n_transport, m_x_transport, m_y_transport = size(U_2d_transport_matrix)
	anim_2d_transform = @animate for i in 1:n_transport
		heatmap(U_2d_transport_matrix[i, :, :], clim=(0,2),
			xticks=(1: m_x_transport, [string(round(j, digits=3)) for j in 0:(1/ m_x_transport-1):1]), 
			yticks=(1: m_y_transport, [string(round(j, digits=3)) for j in 0:(1/ m_y_transport-1):1])
		)
	end
end

# ╔═╡ 125ae9ad-5570-451a-a7bf-e6ba75946310
gif(anim_2d_transform, "graph_animation-2d.gif", fps = 2)

# ╔═╡ Cell order:
# ╠═c8561f88-916c-11ee-19bb-850b3ffa37d8
# ╠═6d7e7e0e-e6e4-4fa8-808b-1ec500a4495d
# ╠═2ed1733a-a4a1-4f5f-9757-20206decd63c
# ╠═d957c5cf-cacf-42d6-8dca-ecd5cb25e42e
# ╠═5e150598-7fe8-4e82-a6d8-b1f833dc4569
# ╠═d30b2b48-7f0c-40f7-8bd0-b908f4d16aed
# ╠═cc8ea44b-60aa-4e3b-80f0-9e161f77923a
# ╠═1ca37473-919c-4be5-bbde-abe6b79ab3fd
# ╠═0cc505a1-832b-40b8-b9a2-2039c080a1d1
# ╠═8f7865b1-e36d-4f4d-9f36-c76b9d4ac3e8
# ╠═8416006e-b059-4e8a-9dc7-d77ce84c7746
# ╠═77c94803-2216-4019-9e87-fcdecd018d17
# ╠═18576797-130d-4fe4-8ef0-34aab35dba8f
# ╠═125ae9ad-5570-451a-a7bf-e6ba75946310
