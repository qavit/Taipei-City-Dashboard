## how to create files

```sh
python process_data orgainization_file.csv city_district_basic.csv out.csv --o-abc category --city city
```

實務使用

```sh
# 新北市 type c
python process_data.py ../長照ABC據點_行政區轉換後_v3.csv new_taipei_district_basic.csv new_taipei_type_c.csv --o-abc C --city 新北市
# 臺北市 type c
python process_data.py ../長照ABC據點_行政區轉換後_v3.csv taipei_district_basic.csv taipei_type_c.csv --o-abc C --city 臺北市
```
