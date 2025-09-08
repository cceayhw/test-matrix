#!/bin/bash


JSON=inspection.json
TODAY=$(date +%Y%m%d)
MD="data/summary.${TODAY}-${1}.md"
[ "${2}" != "" ] && MD="${2}"


cat << EOB > "${MD}"
# Summary

|url|Is Compliant|Has 1st Party Cookies|Has 3rd Party Cookies|Has 1st Party Listeners|Has 3rd Party Listeners|Has 3rdParty Trackers|
|-|-|-|-|-|-|-|
EOB

for i in reports/blacklight-report-*
do
  echo $i
  #for j in www.sonarqube.ucl.ac.uk
  #for j in www.nerve-engineering.ucl.ac.uk
  #for j in genfi3.cs.ucl.ac.uk
  for j in $(ls -1 $i)
  do
    #echo ${i}/${j}/${JSON}

    TGT="${i}/${j}/${JSON}"
    URL=$(cat ${TGT} | jq -r .uri_ins)
    DOMAINS=$(cat ${TGT} | jq -r .hosts.requests.third_party[])
    COOKIES=$(cat ${TGT} | jq -r .reports.cookies)
    COOKIES1=$(cat ${TGT} | jq -r '.reports.cookies.[] | select(.third_party==false)')
    COOKIES1=$([ "${COOKIES1}" == "" ] && echo "no" || echo "yes")
    COOKIES3=$(cat ${TGT} | jq -r '.reports.cookies.[] | select(.third_party==true)')
    COOKIES3=$([ "${COOKIES3}" == "" ] && echo "no" || echo "yes")
    LISTENERS=$(cat ${TGT} | jq -r .reports.behaviour_event_listeners)
    LISTENERS1=$(cat ${TGT} | jq -r '.reports.behaviour_event_listeners.[] | with_entries(select(.key | contains("ucl.ac.uk")))')
    LISTENERS1=$([ "${LISTENERS1}" == "" ] && echo "no" || echo "yes")
    LISTENERS3=$(cat ${TGT} | jq -r '.reports.behaviour_event_listeners.[] | with_entries(select(.key | contains("ucl.ac.uk")|not))'| sed -e 's/{}//g' | uniq -)
    LISTENERS3=$([ "${LISTENERS3}" == "" ] && echo "no" || echo "yes")
    TRACKERS=$(cat ${TGT} | jq -r .reports.third_party_trackers)
    TRACKERS=$([ "${TRACKERS}" == "[]" ] && echo "no" || echo "yes")
    COMPLIANT1=$([ "${COOKIES3}" == "no" -a "${LISTENERS3}" == "no" -a "${TRACKERS}" == "no" ] && echo "yes" || echo "no")

    echo "|${URL}|${COMPLIANT1}|${COOKIES1}|${COOKIES3}|${LISTENERS1}|${LISTENERS3}|${TRACKERS}|${TGT}|" >> "${MD}"

    # echo "{
    #     \"url\": \"${URL}\",
    #     \"is_compliant\": \"${COMPLIANT1}\",
    #     \"has_1st_party_cookies\": \"${COOKIES1}\",
    #     \"has_3rd_party_cookies\": \"${COOKIES3}\",
    #     \"has_1st_party_listeners\": \"${LISTENERS1}\",
    #     \"has_3rd_party_listeners\": \"${LISTENERS3}\",
    #     \"has_3rd_party_trackers\": \"${TRACKERS}\",
    #     \"report\": \"${TGT}\"
    # }," >> summary.json

  done
done
#echo "{}]" >> summary.json