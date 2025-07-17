### A Pluto.jl notebook ###
# v0.20.13

using GeoMet

# ╔═╡ 1
"""
# Test of function calculate_mih

This notebook tests the `calculate_mih` function from the GeoMet package.
"""

# ╔═╡ 2
# Show the function to confirm it's loaded
calculate_mih

# ╔═╡ 3
# Define example parameters
A = 40.0
b = 0.5

# ╔═╡ 4
# Calculate Mih value with example parameters
mih_value = calculate_mih(A, b)

# ╔═╡ 5
# Show the result
mih_value
