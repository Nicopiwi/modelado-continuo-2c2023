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

# ╔═╡ Cell order:
# ╠═c8561f88-916c-11ee-19bb-850b3ffa37d8
# ╠═6d7e7e0e-e6e4-4fa8-808b-1ec500a4495d
# ╠═2ed1733a-a4a1-4f5f-9757-20206decd63c
# ╠═d957c5cf-cacf-42d6-8dca-ecd5cb25e42e
# ╠═5e150598-7fe8-4e82-a6d8-b1f833dc4569
# ╠═d30b2b48-7f0c-40f7-8bd0-b908f4d16aed
