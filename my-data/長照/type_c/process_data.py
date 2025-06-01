import pandas as pd
import argparse

def filter_data(df, o_abc_value, city):
    print(f"filtering {df.shape[0]} organizations...")
    print(f"organization count before filtering: {len(df)}")

    # Filter by O_ABC value
    if o_abc_value:
        df = df[df['O_ABC'] == o_abc_value]
    
    # Filter by 縣市
    if city:
        df = df[df['縣市'] == city]
    
    # log current length
    print(f"organization count with type #{o_abc_value} in {city}: {len(df)}")

    # Remove duplicates based on 機構代碼
    df = df.drop_duplicates(subset=['機構代碼'])
    
    return df

def group_and_count_by_district(df):
    print(f"grouping and counting by district...")
    org_counts = df.groupby('區')['機構代碼'].nunique().reset_index()
    org_counts.columns = ['district', 'organization_count']
    return org_counts

def merge_with_basic_info(org_counts_df, basic_info_df):
    print(f"merging with basic info...")
    merged_df = pd.merge(org_counts_df, basic_info_df, on='district', how='left')
    return merged_df

def main():
    parser = argparse.ArgumentParser(description='Process CSV data with filtering options')
    parser.add_argument('organization_file', help='Input CSV file of the organization data')
    parser.add_argument('basic_info_file', help='Input CSV file of the basic info data')
    parser.add_argument('output_file', help='Output CSV file path')
    parser.add_argument('--o-abc', help='Filter by O_ABC value (e.g., A, B, C)')
    parser.add_argument('--city', help='Filter by 縣市 (e.g., 臺北市、新北市)')
    
    args = parser.parse_args()
    
    org_df = pd.read_csv(args.organization_file)
    print(f"open {args.organization_file} successfully")

    org_filtered_df = filter_data(org_df, args.o_abc, args.city)
    org_counts = group_and_count_by_district(org_filtered_df)

    basic_info_df = pd.read_csv(args.basic_info_file)
    print(f"open {args.basic_info_file} successfully")

    merged_df = merge_with_basic_info(org_counts, basic_info_df)

    merged_df.to_csv(args.output_file, index=False, encoding='utf-8-sig')
    print(f"save {args.output_file} successfully")

if __name__ == '__main__':
    main()