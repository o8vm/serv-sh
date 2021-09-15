#!/bin/sh

#################################################################
# INITIALIZATION
#################################################################

# === Initialization shell envaironment =========================
umask 0022
set -u    
unset IFS 
export LC_ALL='C'
export PATH="$(command -p getconf PATH)${PATH:+:}:${PATH:-}:$(pwd)/skeleton"
cd $(dirname $0)

# === Define Error termination func =============================
print_usage_and_exit () { 
  cat <<-__USAGE 1>&2
	Usage : ${0##*/} [options] 
	        OPTIONS:
	        -f        
	        -p <PORT> 
	        -r '<BRE>'
	        -d <DIR>  
	        -u <USER>
	        -h <HOST>
__USAGE
  exit 1 
} 

# === Comfirm existance of required command =====================
if   command -v socat  >/dev/null; then
  CMD_SOCAT='socat'                    
elif command -v nc     >/dev/null; then
  CMD_NC='nc'                          
  [ -p /tmp/servepipe ] || {           
    mkfifo /tmp/servepipe              
    PIPE='/tmp/servepipe'              
  }                                    
elif command -v netcat >/dev/null; then
  CMD_NETCAT='netcat'                  
  [ -p /tmp/servepipe ] || {           
    mkfifo /tmp/servepipe              
    PIPE='/tmp/servepipe'              
  }                                    
else                                   
  echo 'NO COMMAND' 1>&2               
  exit 1                               
fi                                     

# === Erase unnecessary pipe ====================================
trap "exit 1"          HUP INT PIPE QUIT TERM
trap "rm -f ${PIPE:-}" EXIT    


#################################################################
# Parse Arguments
#################################################################

# === Print the usage when "--help" is put ======================
case "$# ${1:-}" in
  '1 -h'|'1 --help'|'1 --version') print_usage_and_exit;;
esac

# === Getopts ===================================================
# --- 1.Initialize
PORT=1234
LISTEN="TCP-LISTEN"
DOPT="-d docroot"
# -- 2.get opts
while getopts p:d:r:u:h:s OPT
do
  case $OPT in
    p) PORT="$OPTARG"
       ;;
    d) DOPT="-d $OPTARG"
       ;;
    r) ROPT="-r $OPTARG"
       ;;
    u) XUSER="$OPTARG"
       export XUSER
       ;;
    h) XHOST="$OPTARG"
       export XHOST
       ;;
  esac
done
shift $(($OPTIND - 1))


#################################################################
# Run EXOSKELETON
#################################################################

# === Run as a web server =======================================
if [ -n "${CMD_SOCAT:-}" ]; then                                #
  socat ${LISTEN}:${PORT},pktinfo,reuseaddr,fork${SSL:-}   \
  EXEC:"skeleton/core.sh                                        \
  ${DOPT:-} ${ROPT:-}" #2>/dev/null                              #
else                                                            #
 while :                                                        #
  do                                                            #
    cat "$PIPE"                                         |       #
    ${CMD_NC:-}${CMD_NETCAT:-} -l ${PORT}               |       #
    skeleton/core.sh 1>"$PIPE"                          #       #
    [ $? != 0 ] && break                                #       #
  done                                                          #
fi                                                              #

