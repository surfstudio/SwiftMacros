#!/bin/bash

check_value() {
  value="${!1}"
  if [[ -z "$value" ]]; then
    echo "Error: empty '$1'. Configure Hookfile." >&2
    exit 1
  fi
}

check_value "PROJECT_ID"
check_value "WHITELIST_COMMIT_MSG"