#!/bin/bash
# Użycie: run_mr.sh input_dir1 output_dir3
set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 input_dir1 output_dir3"
    exit 1
fi

INPUT_DIR1=$1
OUTPUT_DIR3=$2
JAR="$(dirname "$0")/MapReduce-1.0-SNAPSHOT.jar"

# Usunięcie wyniku z poprzedniego uruchomienia
hdfs dfs -rm -r -f "$OUTPUT_DIR3"

hadoop jar "$JAR" org.example.FoodOrders "$INPUT_DIR1" "$OUTPUT_DIR3"
