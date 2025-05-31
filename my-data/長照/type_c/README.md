# 資料分析

command 形狀

```sh
python process_data orgainization_list.csv district_basic.csv out.csv --o-abc category --city city
```

實際使用

```sh
# 新北 type c
python process_data.py ../長照ABC據點_行政區轉換後_v3.csv district_basic_new_tpe.csv long_term_care_type_c_new_tpe.csv --o-abc C --city 新北市
# 臺北 type c
python process_data.py ../長照ABC據點_行政區轉換後_v3.csv district_basic_tpe.csv long_term_care_type_c_tpe.csv --o-abc C --city 臺北市
```
