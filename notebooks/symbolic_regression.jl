### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ b3a11660-6280-11f0-2566-13729740fb9f
begin
    import Pkg
    Pkg.activate(temp=true)
    
    # Install required packages
    Pkg.add("SymbolicRegression")
    Pkg.add("DataFrames")
    Pkg.add("CSV")
    Pkg.add("Plots")
    Pkg.add("Statistics")
	Pkg.add("HTTP")	
    
    using SymbolicRegression, DataFrames, CSV, Plots, Statistics, HTTP
    println("✅ All packages loaded successfully!")
end

# ╔═╡ 9d40ae90-270d-4492-a655-9e85b1f2708b
begin
    # Load your data (replace with your dataset)
    url = "https://zenodo.org/record/6587598/files/comminution.csv?download=1"
    df = CSV.read(HTTP.get(url).body, DataFrame)
    
    # Clean data
    rename!(df, names(df) .=> [Symbol(replace(n, " " => "_")) for n in names(df)])
    dropmissing!(df)
    
    # Prepare variables (adjust based on your target)
    X = Matrix(select(df, Not([:Fe_ppm])))  # All columns except target
    y = df.Fe_ppm  # Target variable
    
    println("✅ Data prepared: ", size(X,1), " samples with ", size(X,2), " features")
end

# ╔═╡ 0f98968d-82be-40b0-be58-7a2dfeccece3
begin
    # --- Data Preparation ---
    # Convert to proper matrix format (features × samples)
    X_matrix = Matrix(select(df, Not(:Fe_ppm)))'  # Transpose to [features × samples]
    y_vector = Vector{Float64}(df.Fe_ppm)
    
    # Verify dimensions
    @assert size(X_matrix, 2) == length(y_vector) "X must have shape [features × samples]"
    
    # --- Configuration ---
    options = SymbolicRegression.Options(
        binary_operators=[+, -, *, /],
        unary_operators=[sin, cos, exp],
        populations=20,
        population_size=50,
        maxsize=20,
        timeout_in_seconds=60*5,
        progress=true  # Show progress bar
    )
    
    # --- Run Search ---
    hall_of_fame = EquationSearch(
        X_matrix, 
        y_vector,
        niterations=30,
        options=options,
        parallelism=:multithreading
    )
    
    println("✅ Symbolic regression initialized with:")
    println("- Features: ", size(X_matrix, 1))
    println("- Samples: ", size(X_matrix, 2))
    println("- Threads: ", Threads.nthreads())
end

# ╔═╡ 4a9c6d46-c681-48be-8d51-de39bc571b1b
begin
    # --- Get Results ---
    top_equations = calculate_pareto_frontier(X_matrix, y_vector, hall_of_fame, options)
    
    # --- Universal Size Calculation ---
    function get_expr_size(eq)
        try
            # Modern versions (1.12+)
            return length(SymbolicRegression.enumerate_nodes(eq.tree))
        catch e
            try
                # Legacy versions
                return eq.tree.size
            catch
                # Ultimate fallback
                return length(split(string(eq.tree), r"[\+\-\*/]")) + 1
            end
        end
    end
    
    # --- Display Results ---
    println("🏆 Top 5 Discovered Equations:")
    for (i, eq) in enumerate(top_equations[1:5])
        size = get_expr_size(eq)
        println("$i: ", string(eq.tree), 
              "\n   • Score: ", round(eq.score, digits=4),
              " | Size: ", size, " nodes",
              " | Complexity: ", round(eq.score * size, digits=1), "\n")
    end
    
    # --- Improved Plot ---
    sizes = [get_expr_size(eq) for eq in top_equations]
    scores = [eq.score for eq in top_equations]
    
    scatter(scores, sizes,
            xlabel="Score (Lower is Better)",
            ylabel="Expression Size (nodes)",
            title="Solution Frontier (n=$(length(scores)))",
            label="",
            framestyle=:box,
            color=:blue,
            markersize=8,
            markerstrokewidth=0.5,
            xlims=(0, maximum(scores)*1.1),
            ylims=(0, maximum(sizes)*1.1))
    
    # Add trend line
    if length(scores) > 2
        plot!(sort(scores), sort(sizes), 
              line=(:dot, 2, :red), 
              label="Trend")
    end
end

# ╔═╡ Cell order:
# ╠═b3a11660-6280-11f0-2566-13729740fb9f
# ╠═9d40ae90-270d-4492-a655-9e85b1f2708b
# ╠═0f98968d-82be-40b0-be58-7a2dfeccece3
# ╠═4a9c6d46-c681-48be-8d51-de39bc571b1b
