### A Pluto.jl notebook ###
# v0.20.13

using CSV
using DataFrames
using GeoMet
using DecisionTree
using Random
using Statistics

# ╔═╡ 1
md"""
# Random Forest Model with GeoMet Dataset

This notebook demonstrates how to use the `random_forest_model` function from the GeoMet package with the dataset available at [Zenodo 6587598](https://zenodo.org/records/6587598).
"""

# ╔═╡ 2
md"""
## Load the Dataset

We'll load the `comminution.csv` file, which contains measurements associated with the DWT and BWI indexes.
"""

# ╔═╡ 3
url = "https://zenodo.org/record/6587598/files/comminution.csv?download=1"
download_path = "comminution.csv"
download(url, download_path)

df = CSV.File(download_path) |> DataFrame

# ╔═╡ 4
md"""
## Data Overview

Let's take a look at the first few rows of the dataset to understand its structure.
"""

first(df, 5)

# ╔═╡ 5
md"""
## Preprocessing

We'll filter out rows with missing values and ensure all columns are of numeric type.
"""

df_clean = dropmissing(df)
df_clean = select(df_clean, Not([:SampleID, :Location]))

# ╔═╡ 6
md"""
## Train a Random Forest Model

We'll train a Random Forest model using all columns except the target as features.
"""

target = :BWI
model = random_forest_model(df_clean, target)

# ╔═╡ 7
md"""
## Model Evaluation

Let's evaluate the model's performance using Mean Absolute Error (MAE).
"""

y_true = df_clean[:, target]
y_pred = predict(model, Matrix(df_clean[:, Not(target)]))

mae = mean(abs.(y_true .- y_pred))
mae
