### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ 68377912-53b4-11f0-0133-9de6b08ff15e
#importing packages
import Pkg

# ╔═╡ 5191bfc8-326d-46e6-8cea-8040ad167b31
begin
# importing packages
	Pkg.add("GeoMet")
	Pkg.add("Random")
	Pkg.add("Plots")
	Pkg.add("Statistics")
	Pkg.add("DataFrames")
	Pkg.add("Clustering")
	Pkg.add("PlotlyBase")
	Pkg.add("DataFramesMeta")
	Pkg.add("CategoricalArrays")
	Pkg.add("StatsBase")
end

# ╔═╡ 454eda90-a05c-4b4d-b959-27035bde1326
#Importing Packages
begin
	using DataFrames
	using CSV
	using Random
	using Plots
	using Clustering
	using Statistics
	using DataFramesMeta
	using CategoricalArrays
	using StatsBase
	
	Random.seed!(42)  # Random seed to replicable results
end

# ╔═╡ 1bfd7dce-2423-4c5c-83e2-753d3a6b4e10
#Title: Clustering notebook
#Clustering is a data analysis technique that involves grouping similar elements into sets called "clusters." The goal is to identify intrinsic patterns in the data, where elements within the same cluster share common characteristics, while elements in different clusters exhibit distinct features.

# ╔═╡ e5a88976-9fc3-4ab4-89af-e7f04c1acf67
#Importing data
begin
	df = CSV.read("block_model_marvin_slope.csv", DataFrame)#block_model_marvin_slope.csv is a geological block model containing spatial and geometallurgical attributes for each block: X, Y, Z: Block coordinates (meters). AU, CU: Gold and copper grades (g/t and %). Lithology / Simple_Litho: Detailed and simplified rock classifications. Weathering: Weathering code or category. Slope: Slope angle value used in pit design or geotechnical analysis.
	first(df, 5)  # checking the first lines
end

# ╔═╡ e44df0b2-e9d8-4977-bbb7-72a764b165a1
begin
	# counting unique lithologies
	numero_litologias = length(unique(df.Simple_Litho))
	println("Número de litologias únicas: ", numero_litologias)
	
end

# ╔═╡ 8327a653-d996-4045-a9c4-2f36007ff63f
begin

	# Plot of Original Lithologies
	plotly()  #Activate Plotly backend for interactive plots
end
	

# ╔═╡ d28e3ec2-9e27-44a4-8e99-1e92001163ce
begin
# 3D plot
	df.LithoCode = levelcode.(categorical(df.Simple_Litho))
	p1 = scatter3d(df.X, df.Y, df.Z, marker_z=df.LithoCode)
end

# ╔═╡ c8ba1a01-9b92-4c36-a6a8-850d5ba87031
begin
	# Preparing the data for the clustering process
	aux = select(df, [:AU, :CU])
	first(aux, 5)
end

# ╔═╡ 88e2f3bc-d38e-4d60-9955-2dbd4e5dce0f
begin
	# applying the k-means method
	#K-means is a partitioning algorithm that groups data into K clusters, where K is predefined. It starts by randomly selecting K centroids. Data points are assigned to the nearest centroid, then centroids are updated as the mean of their clusters. This process repeats until cluster assignments stabilize and no longer change.


	kmeans_result = kmeans(Matrix(aux)', numero_litologias)#Runs K-means clustering on the transposed data matrix with the specified number of clusters
	df.Cluster = assignments(kmeans_result)#Assigns the resulting cluster labels to a new column in the DataFrame
end

# ╔═╡ 828d1961-ced1-44dc-8af2-c620d6c99cee
#Clusters 3D plot
p2 = scatter3d(
    df.X, df.Y, df.Z,
    marker_z=df.Cluster,
    markersize=3,
    xlabel="X", ylabel="Y", zlabel="Z",
    title="Clusters K-Means",
    colorbar_title="Cluster"
)

# ╔═╡ 0213b77a-d962-464e-a9b1-6c96abbf4ef4
#Both plots side by side, before and after the clustering process.
plot(p1, p2, layout=(1,2), size=(1000,500))

# ╔═╡ 142dccf2-f78f-45f8-9a6c-21be741463b1
begin
	#Mapping clusters to the most frequent lithologies
	cluster_classes = combine(groupby(df, :Cluster), :Simple_Litho => mode => :Moda_Litologia)#Groups data by cluster and finds the most frequent lithology in each cluster
	df.Cluster_Moda = [cluster_classes[cluster_classes.Cluster .== c, :Moda_Litologia][1] for c in df.Cluster]#Assigns the dominant lithology of each cluster back to the corresponding rows in the original DataFrame.
	
end

# ╔═╡ e80f0e73-912a-4472-b916-eb35ce429395
begin
	# Comparison between clusters and original lithologies
	diferentes = filter(row -> row.Cluster_Moda != row.Simple_Litho, df)
	println("Total number of rows: ", nrow(df))
	println("Rows where Cluster ≠ Simple_Litho: ", nrow(diferentes))
	
end

# ╔═╡ Cell order:
# ╠═1bfd7dce-2423-4c5c-83e2-753d3a6b4e10
# ╠═68377912-53b4-11f0-0133-9de6b08ff15e
# ╠═5191bfc8-326d-46e6-8cea-8040ad167b31
# ╠═454eda90-a05c-4b4d-b959-27035bde1326
# ╠═e5a88976-9fc3-4ab4-89af-e7f04c1acf67
# ╠═e44df0b2-e9d8-4977-bbb7-72a764b165a1
# ╠═8327a653-d996-4045-a9c4-2f36007ff63f
# ╠═d28e3ec2-9e27-44a4-8e99-1e92001163ce
# ╠═c8ba1a01-9b92-4c36-a6a8-850d5ba87031
# ╠═88e2f3bc-d38e-4d60-9955-2dbd4e5dce0f
# ╠═828d1961-ced1-44dc-8af2-c620d6c99cee
# ╠═0213b77a-d962-464e-a9b1-6c96abbf4ef4
# ╠═142dccf2-f78f-45f8-9a6c-21be741463b1
# ╠═e80f0e73-912a-4472-b916-eb35ce429395
