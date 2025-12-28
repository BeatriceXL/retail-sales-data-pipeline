import pandas as pd

# data profiling
df = pd.read_csv("data/raw/retail_sales_dataset.csv")
print(df.shape)
print(df.columns.tolist())
print(df.head(3))

# missing values
print(df.isna().sum())

# duplicates
if "Transaction ID" in df.columns:
    print("dup transaction_id:", df["Transaction ID"].duplicated().sum())

# sanity check if columns exist
cols = set(df.columns)
if {"Quantity", "Price per Unit", "Total Amount"}.issubset(cols):
    calc = df["Quantity"] * df["Price per Unit"]
    diff = (df["Total Amount"] - calc).abs()
    print("total_amount mismatch count:", (diff > 1e-6).sum())
    print("max mismatch:", diff.max())


# data cleaning
RAW_PATH = "data/raw/retail_sales_dataset.csv"
CLEAN_PATH = "data/clean/clean_retail_sales_dataset.csv"

df = pd.read_csv(RAW_PATH)

# rename columns to snake_case
df.columns = (
    df.columns
      .str.strip()
      .str.lower()
      .str.replace(" ", "_")
)

# type conversions
df["date"] = pd.to_datetime(df["date"])

numeric_cols = [
    "quantity",
    "price_per_unit",
    "total_amount",
    "age"
]

for col in numeric_cols:
    df[col] = pd.to_numeric(df[col])

# write clean layer
df.to_csv(CLEAN_PATH, index=False)

print("Clean data saved:", df.shape)

print(df.head())