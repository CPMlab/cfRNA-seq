import argparse
import pandas as pd
import numpy as np
from neuroCombat import neuroCombat  # PyComBat 사용

def load_expression_files(input_files):
    """
    여러 개의 정규화된 발현량 파일을 로드하여 하나의 데이터프레임으로 합침.
    """
    data_frames = []
    sample_names = []

    for file in input_files:
        sample_name = file.split("/")[-1].replace(".normalized.txt", "")
        df = pd.read_csv(file, sep='\t', index_col=0)
        df.columns = [sample_name]
        data_frames.append(df)
        sample_names.append(sample_name)

    combined_df = pd.concat(data_frames, axis=1)
    return combined_df, sample_names

def apply_combat(expression_df, batch_info):
    """
    ComBat을 사용하여 배치 효과를 제거.
    """
    batch_series = batch_info.set_index("sample").loc[expression_df.columns, "batch"]

    # ComBat 실행
    combat_data = neuroCombat(
        dat=expression_df.values,
        covars=None,  # Batch correction only, no covariates
        batch=batch_series.values,
        meanOnly=False
    )["data"]

    # 결과를 DataFrame으로 변환
    corrected_df = pd.DataFrame(combat_data, index=expression_df.index, columns=expression_df.columns)
    return corrected_df

def batch_correct(input_files, batch_file, output_file):
    """
    ComBat을 이용한 배치 보정을 수행하고 결과를 저장.
    """
    expression_df, sample_names = load_expression_files(input_files)
    
    # 배치 정보 로드
    batch_info = pd.read_csv(batch_file)
    batch_info = batch_info[batch_info["sample"].isin(sample_names)]

    # 배치 보정 수행
    corrected_df = apply_combat(expression_df, batch_info)
    
    # 결과 저장
    corrected_df.to_csv(output_file, sep='\t')
    print(f"Batch correction 완료: {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ComBat을 이용한 배치 교정 수행")
    parser.add_argument("--input", nargs='+', required=True, help="정규화된 발현량 파일 리스트")
    parser.add_argument("--batch_file", required=True, help="샘플 배치 정보를 포함한 CSV 파일")
    parser.add_argument("--output", required=True, help="배치 교정된 데이터 출력 파일")

    args = parser.parse_args()
    batch_correct(args.input, args.batch_file, args.output)

