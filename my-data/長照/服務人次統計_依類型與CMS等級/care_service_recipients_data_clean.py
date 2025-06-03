import pandas as pd

files_dict = {
    '長期照顧十年計畫2.0_照顧服務_雙北四年資料.xlsx': {
        'file': '長期照顧十年計畫2.0_照顧服務_原始資料.xlsx',
        'has_service_type': True,
        'rows': {
            'type': 3,
            'level': 4,
            'gender': 5,
            'new_taipei': 7,
            'taipei': 8
        }
    },
    '長期照顧十年計畫2.0_交通接送服務_雙北四年資料.xlsx': {
        'file': '長期照顧十年計畫2.0_交通接送服務_原始資料.xlsx',
        'has_service_type': False,
        'rows': {
            'level': 3,
            'gender': 4,
            'new_taipei': 6,
            'taipei': 7
        }
    },
    '長期照顧十年計畫2.0_營養餐飲服務_雙北四年資料.xlsx': {
        'file': '長期照顧十年計畫2.0_營養餐飲服務_原始資料.xlsx',
        'has_service_type': False,
        'rows': {
            'level': 3,
            'gender': 4,
            'new_taipei': 6,
            'taipei': 7
        }
    }
}

years = ['110', '111', '112', '113']

def parse_columns(cols):
    return [str(val).split()[0] for val in cols]

def generate_city_data(city_series, year, level_col, gen_col, type_col=None):
    city_name = str(city_series.iloc[0]).split()[0]
    records = []

    for idx in range(1, len(city_series)):
        count = city_series.iloc[idx]
        if pd.isna(count) or not isinstance(count, (int, float)):
            continue

        row_data = {
            '縣市': city_name,
            '年度': year,
            'CMS 等級': level_col[idx] if idx < len(level_col) else None,
            '性別': gen_col[idx] if idx < len(gen_col) else None,
            '人數': count
        }

        if type_col:
            service_type = type_col[idx] if idx < len(type_col) else None
            row_data['服務類型'] = "總計" if service_type == "總計註" else service_type

        records.append(row_data)

    return pd.DataFrame(records)

# 執行處理所有檔案
for output_name, config in files_dict.items():
    file = config['file']
    has_service_type = config['has_service_type']
    rows = config['rows']

    all_data_new_taipei = []
    all_data_taipei = []

    for year in years:
        df = pd.read_excel(file, sheet_name=year)

        type_col = parse_columns(df.iloc[rows['type']].ffill()) if has_service_type else None
        level_col = parse_columns(df.iloc[rows['level']].ffill())
        gen_col = parse_columns(df.iloc[rows['gender']].ffill())

        df_new_taipei = df.iloc[rows['new_taipei']]
        df_taipei = df.iloc[rows['taipei']]

        df_new_taipei_long = generate_city_data(df_new_taipei, year, level_col, gen_col, type_col)
        df_taipei_long = generate_city_data(df_taipei, year, level_col, gen_col, type_col)

        all_data_new_taipei.append(df_new_taipei_long)
        all_data_taipei.append(df_taipei_long)

    final_new_taipei = pd.concat(all_data_new_taipei, ignore_index=True)
    final_taipei = pd.concat(all_data_taipei, ignore_index=True)
    final_df = pd.concat([final_new_taipei, final_taipei], ignore_index=True)

    final_df.to_excel(output_name, index=False)