
USE default;

-- 1. Tabela z wynikami MapReduce
DROP TABLE IF EXISTS mr_orders;

CREATE EXTERNAL TABLE mr_orders (
    restaurant_id STRING,
    payment_type STRING,
    order_year INT,
    orders_count BIGINT,
    avg_total_price DOUBLE,
    cancelled_count BIGINT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${hiveconf:input_dir3}';


-- 2. Tabela restauracji
DROP TABLE IF EXISTS restaurants;

CREATE EXTERNAL TABLE restaurants (
    restaurant_id STRING,
    name STRING,
    city STRING,
    country STRING,
    cuisine STRING
)
ROW FORMAT SERDE
    'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    'separatorChar' = ',',
    'quoteChar' = '"'
)
STORED AS TEXTFILE
LOCATION '${hiveconf:input_dir4}'
TBLPROPERTIES ('skip.header.line.count'='1');


-- 3. Tabela wynikowa JSONL
DROP TABLE IF EXISTS country_cuisine_stats;

CREATE EXTERNAL TABLE country_cuisine_stats (
    country STRING,
    cuisine STRING,
    total_orders BIGINT,
    avg_total_price DOUBLE,
    cancelled_ratio DOUBLE,
    rank_in_country BIGINT,
    orders_deviation DOUBLE
)
ROW FORMAT SERDE
    'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION '${hiveconf:output_dir6}';


-- 4. Obliczenia
WITH aggregated AS (
    SELECT
        r.country,
        r.cuisine,
        SUM(m.orders_count) AS total_orders,

        SUM(m.avg_total_price * m.orders_count)
            / SUM(m.orders_count) AS avg_total_price,

        CAST(SUM(m.cancelled_count) AS DOUBLE)
            / SUM(m.orders_count) AS cancelled_ratio

    FROM mr_orders m
    JOIN restaurants r
        ON m.restaurant_id = r.restaurant_id

    GROUP BY r.country, r.cuisine
    HAVING SUM(m.orders_count) > 0
),
ranked AS (
    SELECT
        country,
        cuisine,
        total_orders,
        avg_total_price,
        cancelled_ratio,

        RANK() OVER (
            PARTITION BY country
            ORDER BY total_orders DESC
        ) AS rank_in_country,

        CAST(total_orders AS DOUBLE)
            - AVG(total_orders) OVER (
                PARTITION BY country
            ) AS orders_deviation

    FROM aggregated
)

INSERT OVERWRITE TABLE country_cuisine_stats
SELECT
    country,
    cuisine,
    total_orders,
    avg_total_price,
    cancelled_ratio,
    rank_in_country,
    orders_deviation
FROM ranked;
