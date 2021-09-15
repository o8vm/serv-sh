#!/bin/sh
LF=$(printf '\\\n_')
LF=${LF%_}
this=$(dirname $0)
BASE64="$this/../../../skeleton/base64"
IMGFILE="$this/../..$1"
cat <<EOF
hage
<img src="data:image/jpg;base64,$(${BASE64} $IMGFILE)"/>
EOF



