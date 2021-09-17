#!/bin/sh
LF=$(printf '\\\n_')
LF=${LF%_}
this=$(dirname $0)
CGINAME="$this/../../../skeleton/cgi-name"
NAMEREAD="$this/../../../skeleton/nameread"
QUERY="$(printf "%s" $1 | ${CGINAME} | ${NAMEREAD} q -)"
cd ${this}/../../../docroot

#=== 音声保存用のファイルの作成 ==================
FILE=$(mktemp -p .attachments/mp3 --suffix=".mp3")

#=== 音声変換 ===================================

aws polly synthesize-speech \
    --region ap-northeast-1 \
    --language-code ja-JP \
    --output-format mp3 \
    --voice-id Takumi \
    --text "${QUERY}" \
    "${FILE}"

#=== 結果の出力 ==================================
cat<<EOF
<audio controls src="/${FILE}" />
EOF
exit 0

