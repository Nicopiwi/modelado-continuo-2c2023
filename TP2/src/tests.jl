### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 6bd790a4-73bf-454c-997b-5f37aeb3a0d3
using Pkg

# ╔═╡ 964b8886-17d3-432a-a331-3fe65fa2776c
# ╠═╡ show_logs = false
begin
Pkg.activate("../")
Pkg.instantiate()
end

# ╔═╡ e58b21d0-8667-11ee-3880-09e837427615
include("./TP2.jl")

# ╔═╡ 3fec07b7-dd68-43fa-bbf9-06aa0471329d
md"""
## Matrices de cuantización
"""

# ╔═╡ dafc6250-0e2e-4d68-81c9-a2f6618d0c80
begin
quant1 = UInt8[
        16 11 10 16 24 40 51 61;
        12 12 14 19 26 58 60 55;
        14 13 16 24 40 57 69 56;
        14 17 22 29 51 87 80 62;
        18 22 37 56 68 109 103 77;
        24 35 55 64 81 104 113 92;
        49 64 78 87 103 121 120 101;
        72 92 95 98 112 100 103 99
	]

#Extraida de https://cs.stanford.edu/people/eroberts/courses/soco/projects/data-compression/lossy/jpeg/coeff.htm
quant2 = UInt8[
        3 5 7 9 11 13 15 17;
        5 7 9 11 13 15 17 19;
        7 9 11 13 15 17 19 21;
        9 11 13 15 17 19 21 23;
        11 13 15 17 19 21 23 25;
        13 15 17 19 21 23 25 27;
        15 17 19 21 23 25 27 29;
        17 19 21 23 25 27 29 31;
 ]

quant3 = UInt8[
    12  17  21  25  30  36  42  47;
    18  21  26  31  37  43  48  53;
    22  26  30  35  41  47  52  58;
    27  31  35  40  46  52  58  63;
    33  37  41  46  52  58  63  69;
    39  43  47  52  58  63  69  74;
    44  48  52  58  63  69  74  80;
    50  54  58  63  69  74  80  85
]


end

# ╔═╡ 72343052-ee3b-465d-b35e-88754bb30fcc
md"""
### Utilizando la primera matriz de cuantización
"""

# ╔═╡ 5f2d42c9-08a3-41e7-845e-debc53abb289
transformarImagen("../images/bolitas.bmp", quant1)

# ╔═╡ d170bbdd-3eeb-4564-8380-aadf4fde3f8f
recuperarImagen("../images/bolitas")

# ╔═╡ 02b222a5-4e19-4f54-990e-5c04d803470f
transformarImagen("../images/chica.jpg", quant1)

# ╔═╡ 1898908c-4589-485e-85fa-4f20c36ce92f
recuperarImagen("../images/chica")

# ╔═╡ 973edf3f-2856-492b-9606-19aecab01a69
md"""
### Utilizando la segunda matriz de cuantización
"""

# ╔═╡ 034bdd72-9b07-47c9-9d77-75e49bf482df
transformarImagen("../images/bolitas.bmp", quant2)

# ╔═╡ 6579f847-b967-4d39-8377-1b71329f7e43
recuperarImagen("../images/bolitas")

# ╔═╡ 559b9fd6-be69-4ebe-9bfd-857643552a06
transformarImagen("../images/chica.jpg", quant2)

# ╔═╡ 488cfe9e-d77d-48e6-99f6-55869c9c7651
recuperarImagen("../images/chica")

# ╔═╡ c5ee826a-6b7f-43c8-aeed-99c6c597c188
md"""
### Utilizando la tercera matriz de cuantización
"""

# ╔═╡ 8f987497-2849-416d-b0ba-23f9b50cd2d1
transformarImagen("../images/bolitas.bmp", quant3)

# ╔═╡ b6d7ca5d-e3ff-41ac-a99d-669815445fde
recuperarImagen("../images/bolitas")

# ╔═╡ 248679d3-8edd-4e6a-8559-69ff587b1a65
transformarImagen("../images/chica.jpg", quant3)

# ╔═╡ efc14413-6b6e-46fe-944d-281d866c90ca
recuperarImagen("../images/chica")

# ╔═╡ Cell order:
# ╠═6bd790a4-73bf-454c-997b-5f37aeb3a0d3
# ╠═964b8886-17d3-432a-a331-3fe65fa2776c
# ╠═e58b21d0-8667-11ee-3880-09e837427615
# ╟─3fec07b7-dd68-43fa-bbf9-06aa0471329d
# ╠═dafc6250-0e2e-4d68-81c9-a2f6618d0c80
# ╟─72343052-ee3b-465d-b35e-88754bb30fcc
# ╠═5f2d42c9-08a3-41e7-845e-debc53abb289
# ╠═d170bbdd-3eeb-4564-8380-aadf4fde3f8f
# ╠═02b222a5-4e19-4f54-990e-5c04d803470f
# ╠═1898908c-4589-485e-85fa-4f20c36ce92f
# ╟─973edf3f-2856-492b-9606-19aecab01a69
# ╠═034bdd72-9b07-47c9-9d77-75e49bf482df
# ╠═6579f847-b967-4d39-8377-1b71329f7e43
# ╠═559b9fd6-be69-4ebe-9bfd-857643552a06
# ╠═488cfe9e-d77d-48e6-99f6-55869c9c7651
# ╟─c5ee826a-6b7f-43c8-aeed-99c6c597c188
# ╠═8f987497-2849-416d-b0ba-23f9b50cd2d1
# ╠═b6d7ca5d-e3ff-41ac-a99d-669815445fde
# ╠═248679d3-8edd-4e6a-8559-69ff587b1a65
# ╠═efc14413-6b6e-46fe-944d-281d866c90ca
