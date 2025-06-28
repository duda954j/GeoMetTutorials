### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ e4af2040-5429-11f0-1a53-8dc7b0863536
#importing Packages
begin
	import Pkg
	Pkg.add("CSV")
	Pkg.add("DataFrames")
	Pkg.add("Plots")
	Pkg.add("Statistics")
	Pkg.add("LinearAlgebra")
	Pkg.add("MultivariateStats")
	Pkg.add("StatsBase")
	Pkg.add("Colors")
end

# ╔═╡ 0a7b2762-ee3e-4041-b66a-cf244ccbca1b
begin
	Pkg.add("StatsPlots")
end

# ╔═╡ 400d9bb7-e533-4f27-aeec-622ae430fe73
Pkg.add("PlotlyKaleido")

# ╔═╡ 9e367dcc-5314-4c14-8ad0-602717fda213
begin
	using CSV
	using DataFrames
	using Statistics
	using LinearAlgebra
	using Plots
	using MultivariateStats
	using StatsBase
	using Colors
end


# ╔═╡ 8dbde78b-b29c-4594-a7a8-11e80af291a5
using MultivariateStats: fit, PCA, transform, projection


# ╔═╡ 9ebe3973-a24d-4eb4-85de-98760b6b75ae
#Title: PCA on Geological Block Model

#Principal Component Analysis (PCA) is a technique that transforms correlated variables into a new set of uncorrelated variables (principal components), reducing data dimensionality while preserving as much information as possible. This is useful for simplification, visualization, and identifying key patterns.


# ╔═╡ 3a0c57fc-a6ac-4964-8c77-882580e63772
begin
	df = CSV.read("block_model_marvin_slope.csv", DataFrame)
	select!(df, Not(["Lithology", "Simple_Litho", "Weathering"]))  # Drop non-numeric columns
	first(df, 5)
end

# ╔═╡ 91a23f8a-d214-4e6e-8e46-80b534cba2b8
begin
	#Correlation heatmap using Plots with Plotly backend
	using StatsPlots
	plotly()
	
	
	numeric_df = select(df, Not([:X, :Y, :Z]))
	corr_matrix = cor(Matrix(numeric_df))
	labels = names(numeric_df)
	
	heatmap(
	    labels, labels, corr_matrix,
	    c=:coolwarm,
	    title="Correlation Matrix",
	    xlabel="", ylabel="",
	    right_margin=5Plots.mm,
	    size=(600, 500),
	    clim=(-1, 1),
	    aspect_ratio=:equal,
	    colorbar_title="Correlation"
	)
	
end

# ╔═╡ 17ad1079-17e3-4c43-b3f6-30e568c3e853
begin
	# Selecting AU and CU for PCA
	data = Matrix(select(df, [:AU, :CU]))
	
	# Standardizing the data (zero mean, unit variance)
	mean_vals = mean(data, dims=1)
	std_vals = std(data, dims=1)
	data_scaled = (data .- mean_vals) ./ std_vals
	
end

# ╔═╡ 856fcff6-57df-49d0-8b02-fc4fe6bbb835
@show size(data_scaled)


# ╔═╡ aca7f7f4-9900-4199-89a8-963a38c68d9f
begin
	# Apply PCA with 1 component
	data_scaled_T = data_scaled'  
	model = fit(PCA, data_scaled_T; maxoutdim=1)
	
	
	# Transform data into principal component space
	pc1_data = MultivariateStats.transform(model, data_scaled_T)
end

# ╔═╡ 2f28ea0d-f2a2-4d99-ae18-0d82a8a385c2
begin
	@show size(pc1_data)
	@show size(df)
	@show size(model)
	@show size(data_scaled)
end

# ╔═╡ c6ce2789-712d-43fb-9111-33b0d7742309
begin
	pc1_data_t = pc1_data'
	df_pca = DataFrame(PC1 = pc1_data_t[:, 1])
	df_pca.X = df.X
	df_pca.Y = df.Y
	df_pca.Z = df.Z
	
	first(df_pca, 5)
	
end

# ╔═╡ d27fe2ea-402f-48c7-abb3-05b0475ee9b6
begin
    total_var = sum(principalvars(model))
    explained_var_ratio = principalvars(model)[1] / total_var
    println("Explained variance ratio: ", round(explained_var_ratio, digits=4))
    println("Principal component vector: ", projection(model)[:, 1])
end




# ╔═╡ 31476aa6-3358-4f78-bb06-82e148f3f3c3
scatter3d(
    df_pca.X, df_pca.Y, df_pca.Z,
    marker_z = df_pca.PC1,
    markersize = 3,
    xlabel = "X", ylabel = "Y", zlabel = "Z",
    title = "PCA - First Component in 3D Space",
    colorbar_title = "PC1"
)

# ╔═╡ Cell order:
# ╠═e4af2040-5429-11f0-1a53-8dc7b0863536
# ╠═9e367dcc-5314-4c14-8ad0-602717fda213
# ╠═9ebe3973-a24d-4eb4-85de-98760b6b75ae
# ╠═3a0c57fc-a6ac-4964-8c77-882580e63772
# ╠═0a7b2762-ee3e-4041-b66a-cf244ccbca1b
# ╠═400d9bb7-e533-4f27-aeec-622ae430fe73
# ╠═91a23f8a-d214-4e6e-8e46-80b534cba2b8
# ╠═17ad1079-17e3-4c43-b3f6-30e568c3e853
# ╠═856fcff6-57df-49d0-8b02-fc4fe6bbb835
# ╠═aca7f7f4-9900-4199-89a8-963a38c68d9f
# ╠═2f28ea0d-f2a2-4d99-ae18-0d82a8a385c2
# ╠═c6ce2789-712d-43fb-9111-33b0d7742309
# ╠═8dbde78b-b29c-4594-a7a8-11e80af291a5
# ╠═d27fe2ea-402f-48c7-abb3-05b0475ee9b6
# ╠═31476aa6-3358-4f78-bb06-82e148f3f3c3
