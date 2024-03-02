#!/usr/bin/env bash

LAMBDAS=("eks-lightswitch")

function buildLambda {
  LAMBDA=${1}
  echo "building golang lambda ${LAMBDA}"
  pushd ./lambda_functions/${LAMBDA} || exit
  GOOS=linux GOARCH=amd64 go build
  popd
  echo "building golang lambda $LAMBDA completed"
}

for LAMBDA in ${LAMBDAS} ; do
  buildLambda "${LAMBDA}"
done

