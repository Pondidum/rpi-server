#!/bin/sh

variables=$(nomad var list -out terse \
  | xargs -n 1 nomad var get -out json \
  | jq '{ (.Path): .Items }' \
  | jq -cs add)

op item edit Nomad "Variables=${variables}"
