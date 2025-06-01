-- 建立台北市長照服務統計資料表
CREATE TABLE ltc_service_stats_tpe (
    year INTEGER PRIMARY KEY,
    new_applicants INTEGER NOT NULL,
    assessed_people INTEGER NOT NULL,
    serviced_people INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ltc_service_stats_tpe IS '台北市長照服務統計資料';
COMMENT ON COLUMN ltc_service_stats_tpe.year IS '年度';
COMMENT ON COLUMN ltc_service_stats_tpe.new_applicants IS '新申請人數';
COMMENT ON COLUMN ltc_service_stats_tpe.assessed_people IS '評估人數';
COMMENT ON COLUMN ltc_service_stats_tpe.serviced_people IS '服務人數';

-- 建立新北市長照服務統計資料表
CREATE TABLE ltc_service_stats_ntpc (
    year INTEGER PRIMARY KEY,
    new_applicants INTEGER NOT NULL,
    assessed_people INTEGER NOT NULL,
    serviced_people INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ltc_service_stats_ntpc IS '新北市長照服務統計資料';
COMMENT ON COLUMN ltc_service_stats_ntpc.year IS '年度';
COMMENT ON COLUMN ltc_service_stats_ntpc.new_applicants IS '新申請人數';
COMMENT ON COLUMN ltc_service_stats_ntpc.assessed_people IS '評估人數';
COMMENT ON COLUMN ltc_service_stats_ntpc.serviced_people IS '服務人數';

-- 新增台北市資料
INSERT INTO ltc_service_stats_tpe (year, new_applicants, assessed_people, serviced_people) VALUES
(113, 21918, 44530, 51057),
(112, 22242, 39766, 44853),
(111, 19677, 33621, 38759),
(110, 16349, 27892, 33481);

-- 新增新北市資料
INSERT INTO ltc_service_stats_ntpc (year, new_applicants, assessed_people, serviced_people) VALUES
(113, 40169, 62510, 77977),
(112, 36086, 58560, 68758),
(111, 28758, 47341, 57661),
(110, 25277, 38891, 51560);

-- 刪除舊的資料表和相關組件
DROP TABLE IF EXISTS ltc_service_stats;
DELETE FROM query_charts WHERE index = 'ltc_service';
DELETE FROM component_charts WHERE index = 'ltc_service';
DELETE FROM components WHERE index = 'ltc_service';

-- 新增長照服務統計組件資料
INSERT INTO components (
    index,
    name
) VALUES (
    'ltc_service',
    '長照服務統計'
);

-- 新增長照服務統計圖表組件資料
INSERT INTO component_charts (
    index,
    color,
    types,
    unit
) VALUES (
    'ltc_service',
    ARRAY['#4CAF50', '#2196F3', '#FFC107'],
    ARRAY['TimelineSeparateChart', 'TimelineStackedChart'],
    '人'
);

-- 新增台北市長照服務統計圖表資料
INSERT INTO query_charts (
    index,
    time_from,
    source,
    short_desc,
    long_desc,
    use_case,
    links,
    contributors,
    created_at,
    updated_at,
    query_type,
    query_chart,
    city
) VALUES (
    'ltc_service',
    'static',
    '衛生局',
    '記錄台北市長照服務申請及使用統計資料',
    '本資料集記錄台北市長照服務的新申請人數、評估人數及服務人數統計資料，反映長照服務需求及使用情況。資料涵蓋110年至113年的統計數據，可用於分析長照服務發展趨勢。',
    '可應用於長照服務需求分析、服務量能評估等場景。適合支援如「長照服務發展趨勢分析」、「服務需求評估」等應用。也可搭配人口結構資料，進行整合分析，評估服務資源配置是否符合需求。',
    ARRAY['https://ltc.health.gov.tw/'],
    ARRAY['doit'],
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'time',
    $SQL$SELECT 
    make_timestamp(year + 1911, 1, 1, 0, 0, 0) AT TIME ZONE 'Asia/Taipei' as x_axis,
    CASE metric
        WHEN 'new_applicants' THEN '新申請人數'
        WHEN 'assessed_people' THEN '評估人數'
        WHEN 'serviced_people' THEN '服務人數'
    END as y_axis,
    value::float as data
FROM (
    SELECT 
        year,
        unnest(ARRAY['new_applicants', 'assessed_people', 'serviced_people']) as metric,
        unnest(ARRAY[new_applicants, assessed_people, serviced_people]) as value
    FROM ltc_service_stats_tpe
) subquery
ORDER BY year, metric;$SQL$,
    'taipei'
);

-- 新增雙北整體長照服務統計圖表資料（加總）
INSERT INTO query_charts (
    index,
    time_from,
    source,
    short_desc,
    long_desc,
    use_case,
    links,
    contributors,
    created_at,
    updated_at,
    query_type,
    query_chart,
    city
) VALUES (
    'ltc_service',
    'static',
    '衛生局',
    '記錄雙北地區長照服務申請及使用加總統計資料',
    '本資料集記錄雙北地區長照服務的新申請人數、評估人數及服務人數加總統計資料，反映整體大台北地區長照服務需求及使用情況。資料涵蓋110年至113年的統計數據，可用於分析長照服務發展趨勢。',
    '可應用於大台北地區整體長照服務需求分析、服務量能評估等場景。適合支援如「大台北地區長照服務發展趨勢分析」、「整體服務需求評估」等應用。也可搭配人口結構資料，進行整合分析，評估服務資源配置是否符合需求。',
    ARRAY['https://ltc.health.gov.tw/'],
    ARRAY['doit', 'ntpc'],
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    'time',
    $SQL$WITH combined_stats AS (
    SELECT year, new_applicants, assessed_people, serviced_people 
    FROM ltc_service_stats_tpe
    UNION ALL
    SELECT year, new_applicants, assessed_people, serviced_people 
    FROM ltc_service_stats_ntpc
)
SELECT 
    make_timestamp(year + 1911, 1, 1, 0, 0, 0) AT TIME ZONE 'Asia/Taipei' as x_axis,
    CASE metric
        WHEN 'new_applicants' THEN '新申請人數'
        WHEN 'assessed_people' THEN '評估人數'
        WHEN 'serviced_people' THEN '服務人數'
    END as y_axis,
    SUM(value)::float as data
FROM (
    SELECT 
        year,
        unnest(ARRAY['new_applicants', 'assessed_people', 'serviced_people']) as metric,
        unnest(ARRAY[new_applicants, assessed_people, serviced_people]) as value
    FROM combined_stats
) subquery
GROUP BY year, metric
ORDER BY x_axis, y_axis;$SQL$,
    'metrotaipei'
); 