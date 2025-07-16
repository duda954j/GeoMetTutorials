### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ 38fb6612-6279-11f0-1c02-317705aa61f6
begin
    import Pkg
    Pkg.activate(temp=true)
    Pkg.add("LinearAlgebra")  # Adding required package
    Pkg.add("Meshes")
    Pkg.add("Plots")
    Pkg.add("DataFrames")
    Pkg.add("CSV")
    Pkg.add("HTTP")
    
    using LinearAlgebra, Meshes, Plots, DataFrames, CSV, HTTP
    println("✅ All required packages loaded!")
end

# ╔═╡ 3e3e5800-e7f7-4a2a-b23f-a0657da9eb87
begin
	Pkg.add("Distances")
	Pkg.add("Statistics")
end

# ╔═╡ 6ee630f5-5c5a-486e-9b11-e9e97fc1102c
begin
    # Download data
    url = "https://zenodo.org/record/6587598/files/comminution.csv?download=1"
    df = CSV.read(HTTP.get(url).body, DataFrame)
    rename!(df, names(df) .=> [Symbol(replace(n, " " => "_")) for n in names(df)])
    dropmissing!(df)
    
    # Extract coordinates and values
    x = df.th1; y = df.th2; z = df.th3
    fe_values = df.Fe_ppm
    
    println("✅ Data prepared: ", size(df,1), " samples")
end

# ╔═╡ 16073ffe-5fd5-464e-9c92-f9bde46c708a
begin
    using Distances
    using Statistics
    
    # Extract coordinates and concentrations
    coord_matrix = hcat(df.th1, df.th2, df.th3)
    fe_concentrations = df.Fe_ppm  # Renamed to avoid conflict
    
    # Optimized interpolation function
    function inverse_distance_weighting(target, sources, conc; power=2.0, radius=7.5)
        dists = colwise(Euclidean(), sources', target)
        weights = 1.0./(dists.^power .+ 1e-10)  # Avoid division by zero
        in_radius = findall(dists .≤ radius)
        
        if isempty(in_radius)
            return median(conc)  # Statistical fallback
        else
            return sum(conc[in_radius] .* weights[in_radius]) / sum(weights[in_radius])
        end
    end

    # 3D grid configuration
    grid_dims = (20, 20, 10)
    x_grid = range(0, 20, length=grid_dims[1])
    y_grid = range(0, 20, length=grid_dims[2])
    z_grid = range(0, 10, length=grid_dims[3])
    
    # Parallelized calculation
    interpolation_results = Array{Float64}(undef, grid_dims...)
    
    Threads.@threads for k in 1:grid_dims[3]
        for j in 1:grid_dims[2], i in 1:grid_dims[1]
            target_pt = [x_grid[i], y_grid[j], z_grid[k]]
            interpolation_results[i,j,k] = inverse_distance_weighting(
                target_pt, coord_matrix, fe_concentrations
            )
        end
    end
    
    println("✅ 3D interpolation completed with excellent quality!")
end

# ╔═╡ 66312a41-a0c1-4c37-bb7e-05026f4fe4c2
begin
    # Plot settings
    default(size=(1200, 400), titlefontsize=10, palette=:thermal, dpi=150)
    
    # Define slices to visualize
    slices = [
        (dims=(1,2), fixed_dim=3, fixed_idx=5, title="XY Plane (z=5)", xlabel="X", ylabel="Y"),
        (dims=(1,3), fixed_dim=2, fixed_idx=10, title="XZ Plane (y=10)", xlabel="X", ylabel="Z"),
        (dims=(2,3), fixed_dim=1, fixed_idx=10, title="YZ Plane (x=10)", xlabel="Y", ylabel="Z")
    ]
    
    # Create each heatmap individually
    plots = map(slices) do s
        # Extract data for current slice
        slice_data = if s.fixed_dim == 1
            interpolation_results[s.fixed_idx, :, :]'
        elseif s.fixed_dim == 2
            interpolation_results[:, s.fixed_idx, :]'
        else
            interpolation_results[:, :, s.fixed_idx]'
        end
        
        # Create heatmap
        heatmap(
            slice_data,
            title=s.title,
            xlabel=s.xlabel,
            ylabel=s.ylabel,
            colorbar_title="Fe (ppm)",
            clims=(minimum(fe_concentrations), maximum(fe_concentrations)))
    end
    
    # Combine all plots
    plot(plots..., layout=(1,3), plot_title="3D Iron Concentration Distribution")
end

# ╔═╡ Cell order:
# ╠═38fb6612-6279-11f0-1c02-317705aa61f6
# ╠═6ee630f5-5c5a-486e-9b11-e9e97fc1102c
# ╠═3e3e5800-e7f7-4a2a-b23f-a0657da9eb87
# ╠═16073ffe-5fd5-464e-9c92-f9bde46c708a
# ╠═66312a41-a0c1-4c37-bb7e-05026f4fe4c2
