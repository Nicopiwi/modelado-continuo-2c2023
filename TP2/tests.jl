### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 6bd790a4-73bf-454c-997b-5f37aeb3a0d3
using Pkg

# ╔═╡ 964b8886-17d3-432a-a331-3fe65fa2776c
# ╠═╡ show_logs = false
begin
Pkg.activate(".")
Pkg.instantiate()
end

# ╔═╡ e58b21d0-8667-11ee-3880-09e837427615
include("./TP2.jl")

# ╔═╡ 5f2d42c9-08a3-41e7-845e-debc53abb289
transformarImagen("../images/bolitas.bmp", "bolitas_transformado")

# ╔═╡ d170bbdd-3eeb-4564-8380-aadf4fde3f8f
recuperarImagen("./bolitas_transformado")

# ╔═╡ 02b222a5-4e19-4f54-990e-5c04d803470f
transformarImagen("../images/chica.jpg", "chica_transformado")

# ╔═╡ 1898908c-4589-485e-85fa-4f20c36ce92f
recuperarImagen("./chica_transformado")

# ╔═╡ Cell order:
# ╠═6bd790a4-73bf-454c-997b-5f37aeb3a0d3
# ╠═964b8886-17d3-432a-a331-3fe65fa2776c
# ╠═e58b21d0-8667-11ee-3880-09e837427615
# ╠═5f2d42c9-08a3-41e7-845e-debc53abb289
# ╠═d170bbdd-3eeb-4564-8380-aadf4fde3f8f
# ╠═02b222a5-4e19-4f54-990e-5c04d803470f
# ╠═1898908c-4589-485e-85fa-4f20c36ce92f
