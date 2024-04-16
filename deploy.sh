#!/bin/bash

echo "------------------------ Starting Kubectl Deployment Command ----------------------"
NAMESPACE='test-poc'
DEPL_DIR='kubernetes'
# SVC_DIR='~/svc_depl'

# kubectl create namespace $NAMESPACE
kubectl apply -n $NAMESPACE -f "$DEPL_DIR/namespaces.yaml"
kubectl apply -n $NAMESPACE -f "$DEPL_DIR/deployment.yaml"
kubectl apply -n $NAMESPACE -f "$DEPL_DIR/service.yaml"
kubectl get all -n $NAMESPACE

echo "------------------------ Done Kubectl Deployment Command ----------------------"