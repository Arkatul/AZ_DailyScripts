#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

usage="Usage : $(basename "$0") [params]

where params are :
    --help                                      This help
    (mandatory) -e|--db-engine [value]          Database engine
                                                Possible values : postgres, mysql, mariadb, sql
    (mandatory) -g|--app-rg [value]             Web app resource group name
    (mandatory) -a|--app-name [value]           Web app name
    (mandatory) -G|--db-rg [value]              Database resource group name
    (mandatory) -n|--db-name [value]            Database server name (Azure object name, not the fqdn)
    "

case $key in
    --help)
    echo "$usage"
    exit
    ;;
    -e|--db-engine)
    ENGINE="$2"
    shift # past argument
    shift # past value
    ;;
    -g|--app-rg)
    APPRG="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--app-name)
    APPNAME="$2"
    shift # past argument
    shift # past value
    ;;
    -G|--db-rg)
    DBRG="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--db-name)
    DBNAME="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
echo "Querying Azure for $APPNAME Web app possible outbound IP's..."
ip_list=$(az webapp show -g $APPRG -n $APPNAME -o tsv --query possibleOutboundIpAddresses)

echo "Ip's to add to database firewall : $ip_list"
IFS=','
read -a ARR <<< $ip_list
IFS=' '
CNT=1
for i in "${ARR[@]}"; do
    printf "Adding $i ...\n"
    az ${ENGINE} server firewall-rule create -n ${APPNAME}-${CNT} -g ${DBRG} -s ${DBNAME} --start-ip-address ${i} --end-ip-address ${i}
    printf "... Done!\n"
    CNT=$((CNT+1))
done