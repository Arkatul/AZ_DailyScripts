#!/bin/bash

POSITIONAL=()
debug="N"
usage="Show all secrets from an Azure Keyvault

Usage : $(basename "$0") --vault-name [kv-source] (--secrets scr1,scr2,scr3)

where params are :
    --help                                      This help
    (mandatory) -v|--vault [value]              Keyvault name
    (optional)  -s|--secrets                    Secrets list
                                                If ommitted, shows all secrets
    (optional)  --debug                         Shows debugging info
  "
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --help)
    echo "$usage"
    exit
    ;;
    -v|--vault-name)
    KV="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--secrets)
    SECRETS="$2"
    shift # past argument
    shift # past value
    ;;
    --debug)
    debug="Y"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
if [ $debug == "Y" ];
then
    echo " KV : ${KV}"
    echo " SECRETS : ${SECRETS}"
fi
set -- "${POSITIONAL[@]}" # restore positional parameters
echo "Querying Azure for $KV secrets list..."
if [ -z ${SECRETS+x} ];
then
    SRCSCRLIST=$(az keyvault secret list --vault-name $KV -o tsv --query [].name)
    readarray -t SRCSCRARR <<<"$SRCSCRLIST"
else
    IFS=','
    read -a SRCSCRARR <<< $SECRETS
    IFS=' '
fi
for i in "${SRCSCRARR[@]}"; do
    printf "Reading ${i} value ..."
    SCRVAL=$(az keyvault secret show --vault-name $KV -n ${i} -o tsv --query value)
        printf " ${i} : ${SCRVAL}"
done