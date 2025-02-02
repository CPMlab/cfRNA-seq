import argparse
import pandas as pd
import numpy as np

def compute_tpm(counts, lengths):
    """
    TPM 정규화 계산
    """
    rpk = counts / lengths
    norm_factor = np.sum(rpk) / 1e6
    return rpk / norm_factor

def compute_rpkm(counts, lengths):
    """
    RPKM 정규화 계산
    """
    rpk = counts / lengths
    norm_factor = np.sum(counts) / 1e9
    return rpk / norm_factor

def normalize_expression(input_file, output_file, method):
    """
    유전자 발현 정규화 수행
    """
    # featureCounts 출력 파일 로드
    df = pd.read_csv(input_file, sep='\t', comment='#', index_col=0)
    df = df.iloc[:, [0, -1]]  # 유전자 길이, counts 선택
    df.columns = ["Gene_Length", "Counts"]

    # 정규화 수행
    if method == "TPM":
        df["Normalized"] = compute_tpm(df["Counts"], df["Gene_Length"])
    elif method == "RPKM":
        df["Normalized"] = compute_rpkm(df["Counts"], df["Gene_Length"])
    else:
        raise ValueError("지원되지 않는 정규화 방법입니다. TPM 또는 RPKM을 선택하세요.")

    # 결과 저장
    df[["Normalized"]].to_csv(output_file, sep='\t')
    print(f"정규화 완료: {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="유전자 발현 정규화")
    parser.add_argument("--input", required=True, help="featureCounts 출력 파일")
    parser.add_argument("--output", required=True, help="정규화된 데이터 출력 파일")
    parser.add_argument("--method", required=True, choices=["TPM", "RPKM"], help="정규화 방법 선택")
    
    args = parser.parse_args()
    normalize_expression(args.input, args.output, args.method)

