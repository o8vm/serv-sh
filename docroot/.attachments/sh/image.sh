#!/bin/sh
LF=$(printf '\\\n_')
LF=${LF%_}
this=$(dirname $0)
BASE64="$this/../../../skeleton/base64"
PARSRJ="$this/../../../skeleton/parsrj.sh"
IMGFILE="$this/../..$1"

#=== 画像の表示 ========================
cat <<EOF
<img src="data:image/jpg;base64,$(${BASE64} $IMGFILE)"/>
EOF

#=== 物体の検出 ========================
cat <<EOF
<pre>
<code>
EOF
# ここにコマンド
aws rekognition detect-labels \
    --region ap-northeast-1 \

###############
cat <<EOF
</code>
</pre>
EOF

#==== 顔の検出と分析 ====================
cat <<EOF
<pre>
<code>
EOF
# ここにコマンド
aws rekognition detect-faces \
    --region ap-northeast-1 \

###############
cat <<EOF
</code>
</pre>
EOF

exit 0
