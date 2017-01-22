#!/usr/bin/env bash

SECRETKEY=""
API_ROUTE="hook/docker/build"
HOST_PORT="8080"
HOST_IP="10.0.0.110" #staging

while [[ $# -gt 1 ]]
do
  key="$1"

  case $key in
      -e|--env)
        ENVIRONMENT=$(echo "$2" | awk '{print tolower($0)}')
        shift # past argument
        ;;
      -p|--project)
        PROJECT=$(echo "$2" | awk '{print tolower($0)}')
        shift # past argument
        ;;
      -t|--tag)
        TAG=$(echo "$2" | awk '{print tolower($0)}')
        shift # past argument
        ;;
      -b|--branch)
        BRANCH=$(echo "$2" | awk '{print tolower($0)}')
        shift # past argument
        ;;
      -v|--vagrant)
        VAGRANT=$(echo "$2" | awk '{print tolower($0)}')
        shift # past argument
        ;;
      --default)
        echo "DEFAULT"
        DEFAULT=YES
        ;;
      *)
        if [[ $1 == "deploy" ]]; then
          API_ROUTE="hook/deploy"
        fi
        ;;
  esac
    shift # past argument or value
done

if [[ $ENVIRONMENT == "production" ]]; then
  HOST_IP=10.0.0.110
  HOST_PORT=8081
elif [[ $VAGRANT == "true" ]]; then
  HOST_IP=10.0.0.110
  HOST_PORT=8080
fi

printf "========> Deployment Details: \n"
printf "URL: https://$HOST_IP:$HOST_PORT/${API_ROUTE}\n"
echo ENVIRONMENT: "${ENVIRONMENT:-none}"
echo PROJECT: "${PROJECT:-none}"
echo TAG: "${TAG:-none}"
echo VAGRANT: "${VAGRANT}"
#echo BRANCH: "${BRANCH:-none}"

curl -s -H "Content-Type: application/json" \
     -d '{"tgt":"G@hosting:'${PROJECT}' and G@environment:'${ENVIRONMENT}'","ship":"'${PROJECT:-none}'","environment":"'${ENVIRONMENT}'","buildinfo": {"tag": "'build-${TAG:-none}'"},"secretkey":"'${SECRETKEY}'"}' \
     -k "https://$HOST_IP:$HOST_PORT/$API_ROUTE"

printf "\n========> Deployment Started. Track the process checking #dev-ci channel on Slack.\n"
