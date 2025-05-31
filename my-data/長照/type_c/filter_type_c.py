import pandas as pd
import sys

def filter_oabc(input_file, output_file):
    try:
        # Read the CSV file
        df = pd.read_csv(input_file)
        
        # Filter rows where O_ABC is 'C'
        filtered_df = df[df['O_ABC'] == 'C']
        
        # Save the filtered data to a new CSV file
        filtered_df.to_csv(output_file, index=False)
        
        print(f"Successfully filtered data. Found {len(filtered_df)} rows with O_ABC='C'")
        print(f"Filtered data saved to: {output_file}")
        
    except Exception as e:
        print(f"Error occurred: {str(e)}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python filter_type_c.py <input_file.csv> <output_file.csv>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    filter_oabc(input_file, output_file) 