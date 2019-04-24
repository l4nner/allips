#!/bin/bash

for compID in `oci iam compartment list --all | jq -r '.data[] | .id +" "+."lifecycle-state"' | grep "ACTIVE" | awk '{print $1}'`
do
  compID=`oci iam compartment get --compartment-id $compID | jq -r '[.data.id]|.[]'`
  compName=`oci iam compartment get --compartment-id $compID | jq -r '[.data.name]|.[]'`
  printf "\n\nCOMPARTMENT $compName\n"
  for attachment in `oci compute vnic-attachment list -c $compID | jq -r '[.data[].id]|.[]'`
  do
    instance=`oci compute vnic-attachment get --vnic-attachment-id $attachment | jq -r '[.data."instance-id"]|.[]'`
    instName=`oci compute instance get --instance-id $instance | jq -r '[.data."display-name"]|.[]'`
    for vnic in `oci compute vnic-attachment get --vnic-attachment-id $attachment | jq -r '[.data."vnic-id"]|.[]'`
    do
      pubIP=`oci network vnic get --vnic-id $vnic | jq -r '[.data."public-ip"]|.[]'`
      privIP=`oci network vnic get --vnic-id $vnic | jq -r '[.data."private-ip"]|.[]'`
    done
  echo $instName" - "$pubIP" - "$privIP
  done
done
