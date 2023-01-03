#!/bin/bash

POSITIONAL=()
debug="N"
usage="Show all secrets from an Azure Keyvault

Usage : $(basename "$0") --vault-name [kv-source] (--secrets scr1,scr2,scr3)

where params are :
    --help                                      This help
    (mandatory) -v|--vault [value]              Keyvault name
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
fi
if [ $debug == "Y" ];
then
    echo "Commands to be executed : "
    for secret in $(az keyvault \secret list --vault-name $KV -o tsv --query [].name); do
        secret=$(tr -dc '[[:print:]]' <<< "$secret")
        echo "az keyvault secret show --vault-name "${KV}" -n "${secret}" -o tsv --query "value""
    done
fi
for secret in $(az keyvault \secret list --vault-name $KV -o tsv --query [].name); do
    secret=$(tr -dc '[[:print:]]' <<< "$secret")
    value=$(az keyvault secret show --vault-name "${KV}" -n "${secret}" -o tsv --query "value")
    printf "${secret}\t : ${value}\n"
done