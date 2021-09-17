#!/bin/sh
LF=$(printf '\\\n_')
LF=${LF%_}
this=$(dirname $0)
CGINAME="$this/../../../skeleton/cgi-name"
NAMEREAD="$this/../../../skeleton/nameread"
QUERY="$(printf "%s" $1 | ${CGINAME} | ${NAMEREAD} q -)"

#=== 翻訳 =========================
cat <<EOF
<pre>
<code>
EOF
# ここにコマンド
aws translate translate-text \
    --regiton ap-northeast-1 \
    --text "${QUERY}" \
    --source-language-code ja \
    --target-language-code en
################
cat <<EOF
</code>
</pre>
EOF
exit 0
