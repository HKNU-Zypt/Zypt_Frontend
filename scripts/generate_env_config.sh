#!/bin/bash

# .env 파일에서 iOS EnvConfig.xcconfig 파일을 생성하는 스크립트

ENV_FILE=".env"
CONFIG_FILE="ios/Flutter/EnvConfig.xcconfig"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env 파일을 찾을 수 없습니다."
    exit 1
fi

echo "// 자동 생성된 파일 - 수정하지 마세요" > "$CONFIG_FILE"
echo "// .env 파일에서 생성됨" >> "$CONFIG_FILE"
echo "" >> "$CONFIG_FILE"

# .env 파일을 읽어서 xcconfig 형식으로 변환
while IFS='=' read -r key value; do
    # 빈 줄이나 주석 건너뛰기
    if [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    # 공백 제거
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    
    if [[ -n "$key" && -n "$value" ]]; then
        echo "$key=$value" >> "$CONFIG_FILE"
    fi
done < "$ENV_FILE"

echo "EnvConfig.xcconfig 파일이 생성되었습니다." 