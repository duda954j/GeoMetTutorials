### A Pluto.jl notebook ###
# v0.20.13

using GeoMet
using DataFrames

# ╔═╡ 1
"""
# Test of function random_forest_model

This notebook tests the `random_forest_model` function from the GeoMet package.
"""

# ╔═╡ 2
# Create a simple example DataFrame
df = DataFrame(
    feature1 = [1.0, 2.0, 3.0, 4.0, 5.0],
    feature2 = [2.5, 3.5, 1.5, 4.5, 5.5],
    target = [10.0, 20.0, 15.0, 25.0, 30.0]
)

# ╔═╡ 3
# Show the DataFrame
df

# ╔═╡ 4
# Train the Random Forest model to predict :target
model = random_forest_model(df, :target; n_trees=10)

# ╔═╡ 5
# Show the trained model
model

# ╔═╡ 6
# Example: predict the target for new data
new_data = [3.0 2.0]  # feature1=3.0, feature2=2.0
prediction = DecisionTree.predict(model, new_data)

# ╔═╡ 7
# Show the prediction
prediction
