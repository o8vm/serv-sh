#!/bin/sh
LF=$(printf '\\\n_')
LF=${LF%_}
this=$(dirname $0)
BASE64="$this/../../../skeleton/base64"
AXS="$this/../../../skeleton/axs"
PARSRJ="$this/../../../skeleton/parsrj.sh"
IMGFILE="$this/../..$1"
FILENAME="${IMGFILE##*/}"
aws s3 cp ${IMGFILE} s3://shz-workshop/user001/ >/dev/null

cat <<EOF
<img src="data:image/jpg;base64,$(${BASE64} $IMGFILE)"/>
EOF

cat <<EOF
<pre>
<code>
EOF
${AXS} -q <<EOF | ${PARSRJ} | grep -i emotion
POST /
Host: rekognition.ap-northeast-1.amazonaws.com
Content-Type: application/x-amz-json-1.1
X-Amz-Target: RekognitionService.DetectFaces

{
  "Attributes" : [ "ALL" ],
  "Image" : {
     "S3Object" : {
        "Bucket" : "shz-workshop",
        "Name" : "user001/${FILENAME}"
     }
  }
}
EOF
cat <<EOF
</code>
</pre>
EOF



cat <<EOF
<pre>
<code>
EOF
${AXS} -q <<EOF | ${PARSRJ}
POST /
Host: rekognition.ap-northeast-1.amazonaws.com
Content-Type: application/x-amz-json-1.1
X-Amz-Target: RekognitionService.DetectLabels

{
  "Image" : {
     "S3Object" : {
        "Bucket" : "shz-workshop",
        "Name" : "user001/${FILENAME}"
     }
  },
  "MaxLabels": 10,
  "MinConfidence" : 60
}
EOF
cat <<EOF
</code>
</pre>
EOF

