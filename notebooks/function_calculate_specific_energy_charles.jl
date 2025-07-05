### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ 24d37d70-44b2-4eba-87c0-1de655aeb06b
begin
	import Pkg
	Pkg.add("HTTP")
	Pkg.add("CSV")
	Pkg.add("DataFrames")
	Pkg.add("Plots")
	Pkg.add("GeoMet")
end


# ╔═╡ e2ee2360-59dc-11f0-3784-7ba5b030149f
begin
	using Markdown
	using InteractiveUtils
end

# ╔═╡ 3daf1861-fdd5-42c3-b0b6-ac8496da56e7
using HTTP, CSV, DataFrames, Plots, GeoMet


# ╔═╡ cfca2e8f-6d39-44b4-8110-7b5aaa6bdcc0
begin
	url = "https://zenodo.org/record/6587598/files/comminution.csv?download=1"
	resp = HTTP.get(url)
	csv_data = String(resp.body)
end


# ╔═╡ fbed9d12-83d6-4215-af81-f20d8a3c3a6a
begin
	df = CSV.read(IOBuffer(csv_data), DataFrame)
	first(df, 5)
end

# ╔═╡ 0e77d9b3-6308-4f15-ba3d-314691daa9ec
begin
	#calculates the specific energy with the Rittinger method (n = 1.0)
	df.E_specific_rittinger = calculate_specific_energy_charles(df; K=1000.0, n=1.0)
	first(df[:, [:F80, :P80, :E_specific_rittinger]], 5)
end

# ╔═╡ b96852ec-ce90-4f31-81e5-8ac77aa63026


# ╔═╡ 7423d256-8ca6-45ae-9c63-f47efdbdab42


# ╔═╡ Cell order:
# ╠═e2ee2360-59dc-11f0-3784-7ba5b030149f
# ╠═24d37d70-44b2-4eba-87c0-1de655aeb06b
# ╠═3daf1861-fdd5-42c3-b0b6-ac8496da56e7
# ╠═cfca2e8f-6d39-44b4-8110-7b5aaa6bdcc0
# ╠═fbed9d12-83d6-4215-af81-f20d8a3c3a6a
# ╠═0e77d9b3-6308-4f15-ba3d-314691daa9ec
# ╠═b96852ec-ce90-4f31-81e5-8ac77aa63026
# ╠═7423d256-8ca6-45ae-9c63-f47efdbdab42
