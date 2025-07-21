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
# Test of function `calculate_spi` with dataset

This notebook tests the `calculate_spi` function from the GeoMet package using real data from a public geometallurgical dataset.
"""

# ╔═╡ 2
# Download the dataset if it's not already available locally
dataset_url = "https://zenodo.org/records/6587598/files/geometallurgical_data.csv"
csv_path = "geometallurgical_data.csv"

if !isfile(csv_path)
    Downloads.download(dataset_url, csv_path)
end

# ╔═╡ 3
# Load the dataset into a DataFrame
df = CSV.read(csv_path, DataFrame)

# ╔═╡ 4
# Display the first few rows to preview the dataset
first(df, 5)

# ╔═╡ 5
# Check the column names available in the dataset
names(df)

# ╔═╡ 6
# Example usage of the `calculate_spi` function
# We assume that columns :Fe and :S represent two distinct groups
# to be used in calculating the Spatial Proximity Index (SPI).
# Replace with appropriate group columns as needed.

spi_values = calculate_spi(df; group1 = :Fe, group2 = :S)

# ╔═╡ 7
# Display the first 10 SPI results
spi_values[1:10]
