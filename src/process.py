import pandas as pd

data = pd.read_csv("input/FoodFacts.tsv", sep="\t")

conversion = {
    "object": "TEXT",
    "float64": "NUMERIC"
}

sql = """.separator ","

CREATE TABLE FoodFacts (
%s);

.import "working/noHeader/FoodFacts.csv" FoodFacts
""" % ",\n".join(["    %s %s" % (key.replace("-", "_"), conversion[str(data.dtypes[key])]) for key in data.dtypes.keys()])

print(type(data.dtypes))
print(data.dtypes.keys())
print(data.dtypes)
print(type(data.dtypes["code"]))
print(str(data.dtypes["code"])=="object")

data.to_csv("output/FoodFacts.csv", index=False)

open("working/import.sql", "w").write(sql)
