import argparse
import pandas as pd
import heteroDE

def load_data(input_file, batch_file, condition_column):
    """
    배치 교정된 데이터와 샘플 정보를 불러옴.
    """
    expression_data = pd.read_csv(input_file, sep="\t", index_col=0)
    sample_info = pd.read_csv(batch_file)

    if condition_column not in sample_info.columns:
        raise ValueError(f"ERROR: '{condition_column}' column not found in {batch_file}")

    # 샘플 정보에서 condition 정보만 추출
    conditions = sample_info.set_index("sample")[condition_column]

    return expression_data, conditions

def run_heteroDE(expression_data, conditions, output_file):
    """
    HeteroDE를 이용하여 DEG 분석을 수행하고 결과를 저장.
    """
    results = heteroDE.run(expression_data, conditions)

    # 결과 저장
    results.to_csv(output_file, sep="\t")
    print(f"DEG 분석 완료: {output_file}")

def main():
    parser = argparse.ArgumentParser(description="HeteroDE를 이용한 DEG 분석 수행")
    parser.add_argument("--input", required=True, help="배치 교정된 발현량 데이터 파일")
    parser.add_argument("--batch_file", required=True, help="샘플 정보를 포함한 CSV 파일")
    parser.add_argument("--condition_column", required=True, help="DEG 분석에 사용할 조건 컬럼명")
    parser.add_argument("--output", required=True, help="DEG 결과 출력 파일")

    args = parser.parse_args()
    
    expression_data, conditions = load_data(args.input, args.batch_file, args.condition_column)
    run_heteroDE(expression_data, conditions, args.output)

if __name__ == "__main__":
    main()

