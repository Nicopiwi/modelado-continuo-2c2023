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
Pkg.add("Images")
end

# ╔═╡ 4f928c81-08b3-48ec-86c9-b859e00573d1
using StatsBase

# ╔═╡ e58b21d0-8667-11ee-3880-09e837427615
include("./TP2.jl")

# ╔═╡ 05a9e969-be46-499f-9506-223c4c867310
img = prepareImage("../images/chica.jpg")

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

# ╔═╡ 70e70e3c-978c-4e75-b1b9-94cea1642116
typeof(Y)

# ╔═╡ 46df00ec-4c1b-49d3-bfd2-67fcc2477d89
begin
mtest = [
1 2 3 3 5 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 4 4 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 4 5 6 7 8 1 2 3 4 9 6 7 8;
1 1 1 4 5 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 3 5 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 4 4 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 4 5 6 7 8 1 2 3 4 9 6 7 8;
1 1 1 4 5 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8;
1 2 9 4 5 6 7 8 1 2 3 4 5 6 7 8;
1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8;
]

decompresion(compresion(mtest), UInt16(16), UInt16(16))
end

# ╔═╡ 7f3094af-d9dc-463b-8b1a-4f1d15c564a6
begin
	n, m = size(Y)
	n = UInt16(n)
	m = UInt16(m)
	compressedY = compresion(Y)
	compressedCb = compresion(Cb)
	compressedCr = compresion(Cr)
end

# ╔═╡ 5bb523cd-82f4-419e-b77a-389e5cd0e72d
begin
	invY = Matrix{Float32}(decompresion(compresion(Y), n, m))
	invCb = Matrix{Float32}(decompresion(compresion(Cb), UInt16(n ÷ 2), UInt16(m ÷ 2)))
	invCr = Matrix{Float32}(decompresion(compresion(Cr), UInt16(n ÷ 2), UInt16(m ÷ 2)))
end

# ╔═╡ 375451d4-0c22-4a87-94a3-580cabe03e28
begin
	invY2 = applyInverseQuantization(invY, quant)
	invCb2 = applyInverseQuantization(invCb, quant)
	invCr2 = applyInverseQuantization(invCr, quant)
end

# ╔═╡ 20b22202-7196-48c9-ab21-fa15a6d20c14
begin 
	applyInverseTransform(invY2)
	applyInverseTransform(invCb2)
	applyInverseTransform(invCr2)
end

# ╔═╡ 63d7dc65-f236-4c17-9585-ec404e20a51d
inversePooling(invY2, invCb2, invCr2)

# ╔═╡ 02dc6c07-22f6-4ce7-9115-9e6e3a8d0e73
guardado(UInt16(n), UInt16(m), quant,[Vector{Int8}(compressedY),Vector{Int8}(compressedCb), Vector{Int8}(compressedCr)], "pruebaBolitas")

# ╔═╡ 415a8268-80a4-4e87-8a04-d6f663c0c741
begin
_, _, _, iCompressedY, iCompressedCb, iCompressedCr = lectura("pruebaBolitas")
end


# ╔═╡ fd852c3e-fb4e-4fbf-beea-9fe4c3e991db
iCompressedY

# ╔═╡ ea5312ff-1f14-4da9-bacd-ad8c87de33e9
begin
	iY = decompresion(iCompressedY, n, m)
	iCb = decompresion(iCompressedCb, UInt16(n ÷ 2), UInt16(m ÷ 2))
	iCr = decompresion(iCompressedCr, UInt16(n ÷ 2), UInt16(m ÷ 2))
end

# ╔═╡ 09641244-5fe1-4734-84af-5f3d4e4c7da5
# decompresion([4,7,59,90,1,5,62,0,2,7], 16, 8)

# ╔═╡ 92b80202-9d97-496e-8be6-c0316d35049d
# my_zigzag = [1, 2, 4, 7, 5, 3, 4, 6, 8, 9, 6, 5, 6, 6, 9, 8, 6, 7]

# ╔═╡ 4cb6a06c-9649-457d-9848-b6b216ad9213
# rle(my_zigzag)

# ╔═╡ 76f0c07b-7437-4de7-b09c-d28683ba4d18
# comp = compresion([1 2 3 4 5 6; 4 5 6 6 6 6; 7 8 9 9 8 7])

# ╔═╡ 9e03cf7b-f4bb-4c24-83bb-7faec0798eab
# decompresion(comp, 3, 6)

# ╔═╡ 18aace49-381c-4677-8204-92abde4def12
# _zigzagNext(1, 3, true, 3)

# ╔═╡ 158a1020-d42e-4d55-becb-7100fe582dd5
begin
	test1 = applyInverseQuantization(iY,quant)
	test2 = applyInverseQuantization(Matrix{Int16}(iCb),quant)
	test3 = applyInverseQuantization(Matrix{Int16}(iCr),quant)
end

# ╔═╡ 607d929f-9fcf-4700-a0ec-eacf97e293a2
begin 
	applyInverseTransform(test1)
	applyInverseTransform(test2)
	applyInverseTransform(test3)
end

# ╔═╡ 0030a043-f88a-44ea-9985-bb1e9ed249c5
inversePooling(test1,test2,test3)

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
# ╠═70e70e3c-978c-4e75-b1b9-94cea1642116
# ╠═46df00ec-4c1b-49d3-bfd2-67fcc2477d89
# ╠═375451d4-0c22-4a87-94a3-580cabe03e28
# ╠═20b22202-7196-48c9-ab21-fa15a6d20c14
# ╠═63d7dc65-f236-4c17-9585-ec404e20a51d
# ╠═7f3094af-d9dc-463b-8b1a-4f1d15c564a6
# ╠═02dc6c07-22f6-4ce7-9115-9e6e3a8d0e73
# ╠═415a8268-80a4-4e87-8a04-d6f663c0c741
# ╠═fd852c3e-fb4e-4fbf-beea-9fe4c3e991db
# ╠═ea5312ff-1f14-4da9-bacd-ad8c87de33e9
# ╠═09641244-5fe1-4734-84af-5f3d4e4c7da5
# ╠═92b80202-9d97-496e-8be6-c0316d35049d
# ╠═4f928c81-08b3-48ec-86c9-b859e00573d1
# ╠═4cb6a06c-9649-457d-9848-b6b216ad9213
# ╠═76f0c07b-7437-4de7-b09c-d28683ba4d18
# ╠═9e03cf7b-f4bb-4c24-83bb-7faec0798eab
# ╠═18aace49-381c-4677-8204-92abde4def12
# ╠═158a1020-d42e-4d55-becb-7100fe582dd5
# ╠═607d929f-9fcf-4700-a0ec-eacf97e293a2
# ╠═0030a043-f88a-44ea-9985-bb1e9ed249c5
