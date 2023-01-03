#!/bin/bash
KV=kv-edu-heff-dev-wpwa
for list in $(az keyvault \secret list --vault-name $KV -o tsv --query [].name)
do
echo $list
echo "az keyvault secret show --vault-name $KV -n $list -o tsv --query value"
done