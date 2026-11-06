#!/bin/bash
# Użycie: run_hive.sh input_dir3 input_dir4 output_dir6
set -e

if [ $# -ne 3 ]; then
    echo "Usage: $0 input_dir3 input_dir4 output_dir6"
    exit 1
fi

INPUT_DIR3=$1
INPUT_DIR4=$2
OUTPUT_DIR6=$3
HQL="$(dirname "$0")/hive.hql"

# Katalog wynikowy musi istnieć dla tabeli zewnętrznej; czyścimy poprzednie wyniki
hdfs dfs -rm -r -f "$OUTPUT_DIR6"
hdfs dfs -mkdir -p "$OUTPUT_DIR6"
# Serwer Hive może działać jako inny użytkownik niż ten, który uruchamia skrypt
hdfs dfs -chmod -R 777 "$OUTPUT_DIR6" || true
hdfs dfs -chmod -R a+rX "$INPUT_DIR3" "$INPUT_DIR4" || true

# W obrazie apache/hive "hive" otwiera beeline bez połączenia, więc łączymy się z HiveServer2
if beeline -u jdbc:hive2://localhost:10000 -e "show databases;" >/dev/null 2>&1; then
    CMD=(beeline -u jdbc:hive2://localhost:10000 -f "$HQL")
else
    CMD=(hive -f "$HQL")
fi

"${CMD[@]}" \
    --hiveconf input_dir3="$INPUT_DIR3" \
    --hiveconf input_dir4="$INPUT_DIR4" \
    --hiveconf output_dir6="$OUTPUT_DIR6"
