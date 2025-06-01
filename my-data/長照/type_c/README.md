# 資料分析

command 形狀

```sh
python process_data.py long_term_care_orgainization_list.csv district_basic.csv out.csv --o-abc category --city city
```

實際使用

```sh
# 新北 type c
python process_data.py ../長照ABC據點_行政區轉換後_v3.csv district_basic_new_tpe.csv long_term_care_type_c_new_tpe.csv --o-abc C --city 新北市
# 臺北 type c
python process_data.py ../長照ABC據點_行政區轉換後_v3.csv district_basic_tpe.csv long_term_care_type_c_tpe.csv --o-abc C --city 臺北市
```

# 匯入資料庫

## 匯入 dashboard manager

### components

```sql
INSERT INTO components (
  index, name
)
VALUES (
  'long_term_care_type_c',
  'C級長照機構'
);
```

### component_charts

```sql
INSERT INTO component_charts (
  index, color, types, unit
)
VALUES (
  'long_term_care_abc',
  ARRAY['#24B0DD','#56B96D','#F8CF58'],
  ARRAY['DistrictChart', 'ColumnChart'],
  '%'
);
```

### query chart

#### 臺北

```sql
insert into public.query_charts(index, time_from, source, short_desc, long_desc, use_case, links, created_at, updated_at, query_type, query_chart, city)
values (
	'long_term_care_type_c',
	'static',
	'衛生福利部',
	'臺北市各行政區C級長照據點與村里數量統計',
	'本資料集收錄臺北市各行政區C級長照據點（巷弄長照站）的數量統計，包含各行政區的機構數與村里數。資料可協助評估各區域是否符合「每三個村里就有一個C級機構」的長照資源配置標準，反映長照服務的可近性與普及程度。透過分析各行政區的機構密度，可了解長照資源的分布均衡性，協助政策制定者識別資源不足區域，優化長照服務網絡的規劃與配置。',
	'可應用於長照資源配置評估、區域服務可近性分析、政策目標達成度檢視等場景。適合政府單位進行長照政策規劃與資源分配、學術研究單位進行區域資源均衡性研究、社福團體進行服務網絡優化。可進一步結合人口老化資料、地理資訊系統，進行更深入的空間分析，找出資源配置的缺口，確保長照服務的普及性與可及性。',
	ARRAY['https://data.gov.tw/dataset/88270', 'https://data.taipei/dataset/detail?id=6a1dbb4e-e99c-4e67-ab09-f6d83852dc99'],
	CURRENT_TIMESTAMP,
	CURRENT_TIMESTAMP,
	'two_d',
	$SQL$SELECT * FROM (
  SELECT
    "district" AS x_axis,
    ROUND((CAST("organization_count" AS FLOAT) / CAST("village_count" AS FLOAT))::numeric, 3) AS data
  FROM long_term_care_type_c_tpe
) AS t
ORDER BY
  ARRAY_POSITION(
    ARRAY['北投區','士林區','內湖區','南港區','松山區','信義區','中山區','大同區','中正區','萬華區','大安區','文山區'],
    t.x_axis
  );$SQL$,
	'taipei'
)
```

#### 雙北

```sql
insert into public.query_charts(index, time_from, source, short_desc, long_desc, use_case, links, created_at, updated_at, query_type, query_chart, city)
values (
	'long_term_care_type_c',
	'static',
	'衛生福利部',
	'雙北各行政區C級長照據點與村里數量統計',
	'本資料集收錄雙北各行政區C級長照據點（巷弄長照站）的數量統計，包含各行政區的機構數與村里數。資料可協助評估各區域是否符合「每三個村里就有一個C級機構」的長照資源配置標準，反映長照服務的可近性與普及程度。透過分析各行政區的機構密度，可了解長照資源的分布均衡性，協助政策制定者識別資源不足區域，優化長照服務網絡的規劃與配置。',
	'可應用於長照資源配置評估、區域服務可近性分析、政策目標達成度檢視等場景。適合政府單位進行長照政策規劃與資源分配、學術研究單位進行區域資源均衡性研究、社福團體進行服務網絡優化。可進一步結合人口老化資料、地理資訊系統，進行更深入的空間分析，找出資源配置的缺口，確保長照服務的普及性與可及性。',
	ARRAY['https://data.gov.tw/dataset/88270', 'https://data.ntpc.gov.tw/datasets/292443d2-faef-452c-96cd-33053e7369b6'],
	CURRENT_TIMESTAMP,
	CURRENT_TIMESTAMP,
	'two_d',
	$SQL$SELECT * FROM (
  SELECT
    "district" AS x_axis,
    ROUND((CAST("organization_count" AS FLOAT) / CAST("village_count" AS FLOAT))::numeric, 3) AS data
  FROM (
    SELECT * FROM long_term_care_type_c_tpe
    UNION ALL
    SELECT * FROM long_term_care_type_c_new_tpe
  ) AS combined_data
) AS t
ORDER BY
  ARRAY_POSITION(
    ARRAY['北投區','士林區','內湖區','南港區','松山區','信義區','中山區','大同區','中正區','萬華區','大安區','文山區','新莊區','淡水區','汐止區','板橋區','三重區','樹林區','土城區','蘆洲區','中和區','永和區','新店區','鶯歌區','三峽區','瑞芳區','五股區','泰山區','林口區','深坑區','石碇區','坪林區','三芝區','石門區','八里區','平溪區','雙溪區','貢寮區','金山區','萬里區','烏來區'],
    t.x_axis
  );$SQL$,
	'metrotaipei'
)
```

## 匯入 dashboard

### copy from local to docker

```sh
docker cp ./long_term_care_type_c_tpe.csv postgres-data:/tmp/long_term_care_type_c_tpe.csv
docker cp ./long_term_care_type_c_new_tpe.csv postgres-data:/tmp/long_term_care_type_c_new_tpe.csv
```

### create table

```sql
CREATE TABLE IF NOT EXISTS long_term_care_type_c_tpe (
	"district" TEXT NOT NULL,
	"organization_count" INT NOT NULL,
	"village_count" INT NOT NULL
)

CREATE TABLE IF NOT EXISTS long_term_care_type_c_new_tpe (
	"district" TEXT NOT NULL,
	"organization_count" INT NOT NULL,
	"village_count" INT NOT NULL
)
```

### 清空 table

```sql
TRUNCATE TABLE long_term_care_type_c_tpe;
TRUNCATE TABLE long_term_care_type_c_new_tpe;
```

### insert with csv

```sql
COPY long_term_care_type_c_tpe (
    "district",
    "organization_count",
    "village_count"
)
FROM '/tmp/long_term_care_type_c_tpe.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY long_term_care_type_c_new_tpe (
    "district",
    "organization_count",
    "village_count"
)
FROM '/tmp/long_term_care_type_c_new_tpe.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);
```
