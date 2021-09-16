#!/bin/sh
LF=$(printf '\\\n_')
LF=${LF%_}
this=$(dirname $0)
CGINAME="$this/../../../skeleton/cgi-name"
NAMEREAD="$this/../../../skeleton/nameread"
QUERY="$(printf "%s" $1 | ${CGINAME} | ${NAMEREAD} q -)"

cat <<EOF
<pre>
<code>
EOF
# 全部穴抜けでいいと思う
aws translate translate-text --text "${QUERY}" \
    --source-language-code ja \
    --target-language-code en
cat <<EOF
</code>
</pre>
EOF
exit 0
