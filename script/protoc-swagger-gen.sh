#!/usr/bin/env bash
set -eo pipefail 

mkdir -p ./.cache/tmp/swagger-gen
proto_dirs=$(find ./proto -path -prune -o -name '*.proto' -print0 | xargs -0 -n1 dirname | sort | uniq)
for dir in $proto_dirs; do
  # generate swagger files (filter query files)
  query_file=$(find "${dir}" -maxdepth 1 -name 'query.proto')
  if [[ -n "$query_file" ]]; then
    .cache/bin/protoc  \
    -I "proto" \
    -I "vendor/github.com/cosmos/cosmos-sdk/proto" \
    -I "vendor/github.com/cosmos/cosmos-sdk/third_party/proto" \
    "$query_file" \
    --swagger_out ./.cache/tmp/swagger-gen \
    --swagger_opt logtostderr=true --swagger_opt fqn_for_swagger_name=true --swagger_opt simple_operation_ids=true
  fi
done

# combine swagger files
# uses nodejs package `swagger-combine`.
# all the individual swagger files need to be configured in `config.json` for merging
.cache/node_modules/.bin/swagger-combine ./client/docs/config.json \
-o ./client/docs/swagger-ui/swagger.yaml -f yaml \
--continueOnConflictingPaths true \
--includeDefinitions true

# clean swagger files
rm -rf ./.cache/tmp/swagger-gen
