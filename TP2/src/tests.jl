### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ 6bd790a4-73bf-454c-997b-5f37aeb3a0d3
using Pkg

# ╔═╡ 964b8886-17d3-432a-a331-3fe65fa2776c
Pkg.activate(".")

# ╔═╡ e58b21d0-8667-11ee-3880-09e837427615
include("./TP2.jl")

# ╔═╡ 05a9e969-be46-499f-9506-223c4c867310
img = prepareImage("../images/bolitas.bmp")

# ╔═╡ 3ab142f6-8a6d-4cdf-814d-c0adb6971a4a
Y, Cb, Cr = pooling(img)

# ╔═╡ fe5c2a48-1285-4dc4-9d12-42cc951fd59c
begin
	applyTransform(Y)
	applyTransform(Cb)
	applyTransform(Cr)
end

# ╔═╡ bb4b7749-ba52-4e8e-8f7f-186aa750f552
quant=UInt8[16 11 10 16 24 40 51 61;
           12 12 14 19 26 58 60 55;
           14 13 16 24 40 57 69 56;
           14 17 22 29 51 87 80 62;
           18 22 37 56 68 109 103 77;
           24 35 55 64 81 104 113 92;
           49 64 78 87 103 121 120 101;
           72 92 95 98 112 100 103 99]

# ╔═╡ 87686890-72bd-447d-86cf-82bb030b0394
begin
	applyQuantization(Y, quant)
	applyQuantization(Cb, quant)
	applyQuantization(Cr, quant)
end

# ╔═╡ 5bb523cd-82f4-419e-b77a-389e5cd0e72d
begin
	compressedY = compresion(Y)
	compressedCb = compresion(Cb)
	compressedCr = compresion(Cr)
end

# ╔═╡ 7f3094af-d9dc-463b-8b1a-4f1d15c564a6
begin
	n, m = size(Y)
end

# ╔═╡ 02dc6c07-22f6-4ce7-9115-9e6e3a8d0e73
guardado(UInt16(n), UInt16(m), quant, Vector{Int8}(compressedY), Vector{Int8}(compressedCb), Vector{Int8}(compressedCr), "pruebaBolitas")

# ╔═╡ 415a8268-80a4-4e87-8a04-d6f663c0c741
_, _, _, iCompressedY, iCompressedCb, iCompressedCr = lectura("pruebaBolitas.imc")

# ╔═╡ ea5312ff-1f14-4da9-bacd-ad8c87de33e9
begin
	iY = decompresion(iCompressedY, n, m)
	iCb = decompresion(iCompressedCb, n/2, m/2)
	iCr = decompresion(iCompressedCr, n/2, m/2)
end

# ╔═╡ Cell order:
# ╠═6bd790a4-73bf-454c-997b-5f37aeb3a0d3
# ╠═964b8886-17d3-432a-a331-3fe65fa2776c
# ╠═e58b21d0-8667-11ee-3880-09e837427615
# ╠═05a9e969-be46-499f-9506-223c4c867310
# ╠═3ab142f6-8a6d-4cdf-814d-c0adb6971a4a
# ╠═fe5c2a48-1285-4dc4-9d12-42cc951fd59c
# ╠═bb4b7749-ba52-4e8e-8f7f-186aa750f552
# ╠═87686890-72bd-447d-86cf-82bb030b0394
# ╠═5bb523cd-82f4-419e-b77a-389e5cd0e72d
# ╠═7f3094af-d9dc-463b-8b1a-4f1d15c564a6
# ╠═02dc6c07-22f6-4ce7-9115-9e6e3a8d0e73
# ╠═415a8268-80a4-4e87-8a04-d6f663c0c741
# ╠═ea5312ff-1f14-4da9-bacd-ad8c87de33e9
