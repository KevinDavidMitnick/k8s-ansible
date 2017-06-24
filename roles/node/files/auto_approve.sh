#!/usr/bin/env bash
csr=$(kubectl get csr | grep Pending | awk '{print $1}')

for i in ${csr};do
    kubectl certificate approve $i
done
