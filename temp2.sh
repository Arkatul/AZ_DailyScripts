#!/bin/bash
KV=kv-edu-heff-dev-wpwa
item=environment
az keyvault secret show --vault-name $KV -n $item -o tsv --query value