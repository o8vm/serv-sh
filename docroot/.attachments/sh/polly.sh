#!/bin/sh
LF=$(printf '\\\n_')
LF=${LF%_}
this=$(dirname $0)
CGINAME="$this/../../../skeleton/cgi-name"
NAMEREAD="$this/../../../skeleton/nameread"
QUERY="$(printf "%s" $1 | ${CGINAME} | ${NAMEREAD} q -)"
cd ${this}

FILE=$(mktemp -p ../mp3 --suffix=".mp3")

aws polly synthesize-speech --language-code ja-JP \
    --output-format mp3 \
    --voice-id Takumi \
    --text "${QUERY}" \
    "${FILE}"

FILE=${FILE#*/}
DIRPATH=${this#*/}
DIRPATH=${DIRPATH%/*}
cat<<EOF
<audio controls src="/${DIRPATH}/${FILE}" />
EOF
exit 0
