--- docker

docker cp ./tim-scripts/新北市老人分佈.csv postgres-data:/tmp/elderly-dist-newtaipei.csv
docker cp ./tim-scripts/台北市老人分佈.csv postgres-data:/tmp/elderly-dist-taipei.csv


--- dashboard


create table elderly_dist_newtaipei (
	district varchar(255),
	count int
);


copy "elderly_dist_newtaipei" (
district,
count
)
from '/tmp/elderly-dist-newtaipei.csv'
with(
format csv,
header,
encoding 'utf8'
);


create table elderly_dist_taipei (
	district varchar(255),
	count int
);


copy "elderly_dist_taipei" (
district,
count
)
from '/tmp/elderly-dist-taipei.csv'
with(
format csv,
header,
encoding 'utf8'
);


--- dashboard manager

insert into public.components(
	index,
	name
)
values (
	'elderly_dist',
	'全市高齡人口分布'
);


insert into public.component_charts (
	index,
	color,
	types,
	unit
)
values(
	'elderly_dist',
	array['#28A745', '#66BB6A', '#C0E218', '#FFCD38', '#7ED6A2', '#B2C248', '#586C3F', '#1B3D2F'],
	array['DistrictChart','ColumnChart'],
	'人'
);


insert into public.query_charts (index, history_config, map_config_ids, map_filter, time_from, time_to, update_freq, update_freq_unit, source, short_desc, long_desc, use_case, links, contributors, created_at, updated_at, query_type, query_chart, query_history, city)
values ('elderly_dist', NULL, NULL, NULL, 'static', NULL, NULL, NULL, '主計處', '顯示雙北高齡族群分區', NULL, NULL, '{https://data.ntpc.gov.tw/datasets/8308ab58-62d1-424e-8314-24b65b7ab492,https://data.taipei/dataset/detail?id=64c8a3a0-3b9a-4f49-a13a-fb1eb2ffa4b1}', '{tuic,ntpc}', '2025-06-01 00:18:00+00', '2025-06-01 00:18:00+00', 'two_d', 'SELECT x_axis, SUM(data) AS data FROM ( SELECT district AS x_axis, "count" AS data FROM public.elderly_dist_taipei UNION ALL SELECT district AS x_axis, "count" AS data FROM public.elderly_dist_newtaipei) AS combined GROUP BY x_axis;', NULL, 'metrotaipei');


insert into public.query_charts (index, history_config, map_config_ids, map_filter, time_from, time_to, update_freq, update_freq_unit, source, short_desc, long_desc, use_case, links, contributors, created_at, updated_at, query_type, query_chart, query_history, city)
values ('elderly_dist', NULL, NULL, NULL, 'static', NULL, NULL, NULL, '主計處', '顯示台北高齡族群分區', NULL, NULL, '{https://data.taipei/dataset/detail?id=64c8a3a0-3b9a-4f49-a13a-fb1eb2ffa4b1}', '{tuic}', '2025-05-31 22:42:00+00', '2025-05-31 22:42:00+00', 'two_d', 'SELECT district AS x_axis, count AS data FROM public.elderly_dist_taipei ORDER BY data desc', NULL, 'taipei');



SELECT x_axis, SUM(data) AS data
FROM (
    SELECT district AS x_axis, "count" AS data
    FROM public.elderly_dist_taipei
    UNION ALL
    SELECT district AS x_axis, "count" AS data
    FROM public.elderly_dist_newtaipei
) AS combined
GROUP BY x_axis;



--- if i fuck things up in query_charts
--- ignore below

delete from public.query_charts where index='elderly_dist';



