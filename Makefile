
input/FoodFacts.tsv:
	mkdir -p input
	curl http://world.openfoodfacts.org/data/en.openfoodfacts.org.products.csv -o input/FoodFacts.tsv
input: input/FoodFacts.tsv

output/FoodFacts.csv:
	mkdir -p working
	mkdir -p output
	python src/process.py
csv: output/FoodFacts.csv

working/noHeader/FoodFacts.csv: output/FoodFacts.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

output/database.sqlite: working/noHeader/FoodFacts.csv
	-rm output/database.sqlite
	sqlite3 -echo $@ < working/import.sql
db: output/database.sqlite

output/hashes.txt: output/database.sqlite
	-rm output/hashes.txt
	echo "Current git commit:" >> output/hashes.txt
	git rev-parse HEAD >> output/hashes.txt
	echo "\nCurrent ouput md5 hashes:" >> output/hashes.txt
	md5 output/*.csv >> output/hashes.txt
	md5 output/*.sqlite >> output/hashes.txt
	md5 input/*.tsv >> output/hashes.txt
hashes: output/hashes.txt

release: output/database.sqlite output/hashes.txt
	cp -r output world-food-facts
	zip -r -X output/world-food-facts-release-`date -u +'%Y-%m-%d-%H-%M-%S'` world-food-facts/*
	rm -rf world-food-facts

all: csv db hashes release

clean:
	rm -rf working
	rm -rf output
