#!/bin/sh
umask 0022
set -u    
unset IFS 
export LC_ALL='C'
export PATH="$(command -p getconf PATH)${PATH:+:}:${PATH:-}:$(pwd)/skeleton"

# === Getopts ===================================================
# --- 1.Initialize
REGEX='/.*'
# --- 2.Get opts
while getopts d:r: OPT
do
    case $OPT in
        d) DOCROOT="$OPTARG"
	   ;;
        r) REGEX="$OPTARG"
           ;;
    esac
done
shift $(($OPTIND - 1))
DOCROOT=${DOCROOT-docroot}

#===============================================================#
# SET REQUEST LINE                                              #
#===============================================================#
#                                                               #
# === Read Request LINE ======================================= #
read -r LINE || {                                               #
  response 400 <<-RESPONSE
	<html><body><h1>400 Bad Request</h1></body></html>
	RESPONSE
  exit 0;                                                       #
}                                                               #
read -r REQUEST_METHOD RAW_URI REQUEST_HTTP_VERSION        <<-END
	$(# --- for current process --------------------------- #
	printf "%s" "$LINE"                                     |
	tr -d '[\r\n]'                                          )
	END
[ -n "$REQUEST_METHOD" ]       &&                               \
[ -n "$RAW_URI"        ]       &&                               \
[ -n "$REQUEST_HTTP_VERSION" ] || {                             #
  response 400 <<-________RESPONSE
	<html><body><h1>400 Bad Request</h1></body></html>
________RESPONSE
  exit 0;
}                                                               #
REQUEST_URI="${RAW_URI%%\?*}"                                   #
if printf "%s" "$RAW_URI" | grep '?' >/dev/null 2>&1 ;
then
  QUERY_STRING="${RAW_URI#*\?}"                                 #
else
  QUERY_STRING=
fi
#                                                               #
# === Match the REQUEST_URI =================================== #
printf "%s" "${REQUEST_URI}"                                    |
if ! grep "$REGEX" >/dev/null                                   #
then                                                            #
  response 400 <<-________RESPONSE
        <html><body><h1>400 Bad Request</h1></body></html>
________RESPONSE
  exit 0;                                                       #
fi                                                              #
#                                                               #
# === Sanitaize REQUEST_URI =================================== #
URL_PATH="${DOCROOT}${REQUEST_URI%%[!a-zA-Z0-9_~\-\.\/]*}"      #
#                                                               #
#===============================================================#
# END SET REQUEST LINE                                          #
#===============================================================#

case "${REQUEST_METHOD}" in
  GET     ) # --- GET METHOD ------------------------------------- #
    target=$(chamber -m GET                                        \
	    -u "${REQUEST_URI:-N}"                                       \
	    -q "${QUERY_STRING:-N}"                                      )
    if [ ! -n "${target:-}"  ];
    then
      GET.sk -q "${QUERY_STRING:-N}" "${URL_PATH}" "${target:-}"
    else
      response 500 <<-END
	<html><body><h1>500 Internal server error/h1></body></html>
	END
    fi
    ;;
  PUT     ) # --- PUT METHOD ------------------------------------- #
    target=$(chamber -m PUT -v                                     \
	    -u "${REQUEST_URI:-N}"                                       \
	    -q "${QUERY_STRING:-N}"                                      )
    if [  -n "${target:-}"   ];
    then
      PUT.sk -q "${QUERY_STRING:-N}" "${URL_PATH}" "${target:-}"
    else
      response 403 <<-END
	<html><body><h1>403 Forbidden</h1></body></html>
	END
    fi
    ;;
  POST    ) # --- POST METHOD ------------------------------------ #
    target=$(chamber -m POST -v                                    \
            -p "${URL_PATH}"                                       \
	    -u "${REQUEST_URI:-N}"                                       \
	    -q "${QUERY_STRING:-N}"                                      )
    if [ -n "${target:-}"    ];
    then
      POST.sk -q "${QUERY_STRING:-N}" "${URL_PATH}" "${target:-}"
    else
      response 403 <<-END
	<html><body><h1>403 Forbidden</h1></body></html>
	END
    fi
    ;;
  DELETE  ) # --- DELETE METHOD ---------------------------------- #
    target=$(chamber -m DELETE -v                                  \
	    -u "${REQUEST_URI:-N}"                                       \
	    -q "${QUERY_STRING:-N}"                                      )
    if [ -n "${target:-}"    ];
    then
      DELETE.sk -q "${QUERY_STRING:-N}" "${URL_PATH}" "${target:-}"
    else
      response 403 <<-END
	END
    fi
    ;;
  HEAD    ) # --- HEAD METHOD ------------------------------------ #
    target=$(chamber -m HEAD                                       \
            -u "${REQUEST_URI:-N}"                                 \
            -q "${QUERY_STRING:-N}"                                )
    if [ -n "${target:-}"    ];
    then
      HEAD.sk -q "${QUERY_STRING:-N}" "${URL_PATH}" "${target:-}"
    else
      response 403 <<-END
	<html><body><h1>403 Forbidden</h1></body></html>
	END
    fi
    ;;
  PATCH   ) # --- POST METHOD ------------------------------------ #
    target=$(chamber -m PATCH -v                                   \
            -u "${REQUEST_URI:-N}"                                 \
            -q "${QUERY_STRING:-N}"                                )
    if [ -n "${target:-}"    ];
    then
      PATCH.sk -q "${QUERY_STRING:-N}" "${URL_PATH}" "${target:-}"
    else
      response 403 <<-END
	<html><body><h1>403 Forbidden</h1></body></html>
	END
    fi
    ;;
  OPTIONS )  # --- OPTIONS METHOD -------------------------------- #
    target=$(chamber -m OPTIONS                                    \
            -u "${REQUEST_URI:-N}"                                 \
            -q "${QUERY_STRING:-N}"                                )
    if [ -n "${target:-}"    ];
    then
      OPTIONS.sk -q "${QUERY_STRING:-N}" "${URL_PATH}" "${target:-}"
    else
      response 403 <<-END
	<html><body><h1>403 Forbidden</h1></body></html>
	END
    fi
    ;;
  *       ) # --- METHOD NOT ALLOWED ----------------------------- #
    response 405 <<-END
	<html><body><h1>405 Method Not Allowed</h1></body></html>
	END
    ;;
esac

