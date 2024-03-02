#!/usr/bin/env bash

aws eks get-token --cluster-name "$1" --region "$2" --output json