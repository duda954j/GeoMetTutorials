### A Pluto.jl notebook ###
# v0.20.13

begin
	using GeoMet
	using CSV
	using DataFrames
	using Downloads
end

# ╔═╡ 1
"""
# Test of function `calculate_mih` with dataset

This notebook tests the `calculate_mih` function from the GeoMet package using real data from a public geometallurgical dataset.
"""

# ╔═╡ 2
# Download the dataset if not already present
dataset_url = "https://zenodo.org/records/6587598/files/geometallurgical_data.csv"
csv_path = "geometallurgical_data.csv"

if !isfile(csv_path)
    Downloads.download(dataset_url, csv_path)
end

# ╔═╡ 3
# Load the dataset
df = CSV.read(csv_path, DataFrame)

# ╔═╡ 4
# Preview the dataset
first(df, 5)

# ╔═╡ 5
# Check available column names
names(df)

# ╔═╡ 6
# Calculate MIH values using the GeoMet function
mih_values = calculate_mih(df; A=:A, b=:b)

# ╔═╡ 7
# Display some results
mih_values[1:10]
