#!/bin/sh
LF=$(printf '\\\n_')
LF=${LF%_}
this=$(dirname $0)
CGINAME="$this/../../../skeleton/cgi-name"
NAMEREAD="$this/../../../skeleton/nameread"
QUERY="$(printf "%s" $1 | ${CGINAME} | ${NAMEREAD} q -)"
cd $this/../../../docroot

cat<<EOF
<pre>
<code>
EOF
# ここにコマンド
# 検索に使える文字列は QUERY 変数の中に格納されている

cat<<EOF
</code>
</pre>
EOF
exit 0
