#!/bin/bash

URL=$1
DEPTH="${2:-2}"

          EX_FILES='.(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|js)'
          time $HOME/go/bin/gospider -d ${DEPTH} -c 10 --blacklist "${EX_FILES}" -s ${URL} |\
            tr -d '\r' |\
            grep -v -E '\[(form|subdomains|linkfinder|javascript)\]' |\
            grep -v -E 's/(.js|.css|.jpg|favicon.ico|.svg|.pdf)$//g' |\
            grep -v -E 's/(.js|.css)?ver=//g' | grep -v '\[code-40?\]'|\
            sed -e 's/^.* - //g' -e 's/http:/https:/g' -e 's/\/$//g' |\
            grep -v '^mailto:' | grep "^${URL}" |\
            grep -v wp-json/oembed |\
            sort -u > gospider.out

          export ENTRIES=$(wc -l gospider.out | cut -d ' ' -f1)
          echo "# entries: ${ENTRIES}"
          echo "(l(${ENTRIES})/l(50))+1" | bc -l 
          BIG_O=$(echo "(l(${ENTRIES})/l(50))+1" | bc -l | sed 's/\.[0-9]*$//g')
          echo $BIG_O
          SIZE=L
          case "${BIG_O}" in
            "0")
              SIZE= ;;
            "1")
              SIZE=S ;;
            "2" | "3" )
              SIZE=M ;;
            *)
              SIZE=L ;;
          esac

TMP_FILE=tmp.%%
if [ "${CI} == "true" ]
then
  GITHUB_OUTPUT=${TMP_FILE}
  GITHUB_STEP_SUMMARY=${TMP_FILE}
fi
          echo "entries=${ENTRIES}" >> "$GITHUB_OUTPUT"
          echo "big_o=${BIG_O}" >> "$GITHUB_OUTPUT"
          echo "size=${SIZE}" >> "$GITHUB_OUTPUT"
          seq \{1..${BIG_O}\}

          echo "### URL: [${URL}] crawl depth: [${DEPTH}]" >> $GITHUB_STEP_SUMMARY
          echo "### Crawled page count: [${ENTRIES}]" >> $GITHUB_STEP_SUMMARY
          echo "### Big O: [${BIG_O}] size is [${SIZE}]" >> $GITHUB_STEP_SUMMARY

[ -f "${TMP_FILE}" ] && cat "${TMP_FILE}" && rm "${TMP_FILE}"
