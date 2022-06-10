#!/bin/sh

kubectl config set-credentials "${1:-oidc}" \
  --exec-api-version=client.authentication.k8s.io/v1beta1 \
  --exec-command=kubectl \
  --exec-arg=oidc-login \
  --exec-arg=get-token \
  --exec-arg=--oidc-issuer-url=https://auth.mareo.fr/application/o/kubernetes/ \
  --exec-arg=--oidc-client-id=kubernetes \
  --exec-arg=--oidc-extra-scope=profile \
  --exec-arg=--oidc-extra-scope=email
