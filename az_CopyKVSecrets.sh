#!/bin/bash

POSITIONAL=()
debug="N"
usage="Copies All secrets or a selection from one key vault to another

Usage : $(basename "$0") --vault-source [kv-source] --vault-dest [kv-destination] (--secrets scr1,scr2,scr3)

!!! Existing destination secrets will have a new version created !!! 


where params are :
    --help                                      This help
    (mandatory) --vault-source [value]          Source Keyvault
    (mandatory) --vault-dest [value]            Destination Keyvault
    (optional)  -s|--secrets                    Secrets list to copy
                                                If ommitted, copies all secrets
    (optional)  --debug                         Shows debugging info and does not remove temp files
                                                Cleanup after yourself!
  "
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --help)
    echo "$usage"
    exit
    ;;
    --vault-source)
    KVSRC="$2"
    shift # past argument
    shift # past value
    ;;
    --vault-dest)
    KVDEST="$2"
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
    echo " KVSRC : ${KVSRC}"
    echo " KVDEST : ${KVDEST}"
    echo " SECRETS : ${SECRETS}"
fi
set -- "${POSITIONAL[@]}" # restore positional parameters
echo "Querying Azure for $KVSRC secrets list..."
if [ -z ${SECRETS+x} ];
then
    SRCSCRLIST=$(az keyvault secret list --vault-name $KVSRC -o tsv --query [].name)
    readarray -t SRCSCRARR <<<"$SRCSCRLIST"
else
    IFS=','
    read -a SRCSCRARR <<< $SECRETS
    IFS=' '
fi
CNT=1
for i in "${SRCSCRARR[@]}"; do
    printf "Reading ${i} value ..."
    SCRVAL=$(az keyvault secret show --vault-name ${KVSRC} -n ${i} -o tsv --query value)
    echo -n ${SCRVAL}  > SCR${CNT}.tmp
    if [ $debug == "Y" ]; 
    then
        printf " done, value : ${SCRVAL}, copying ..."
    else 
        printf " done, copying ..."
    fi
    az keyvault secret set --vault-name ${KVDEST} -n ${i} -f SCR${CNT}.tmp -o tsv --query none
    if [ $debug == "Y" ]; 
    then 
        printf " File created : SCR${CNT}.tmp, "
    else
        rm SCR${CNT}.tmp
    fi
    printf " done!\n"
    CNT=$((CNT+1))
done