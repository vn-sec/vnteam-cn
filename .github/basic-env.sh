#!/bin/bash

function is_abs_path() {
  [[ "$1" == /* ]] && return 0
  [[ "$1" =~ ^[a-zA-Z]:/ ]] && return 0
  return 1
}

function fmt_abs_path() {
  if [[ "$1" =~ ^/[a-zA-Z]/ ]] || [[ "$1" =~ /[a-zA-Z]$ ]]; then
    if [[ "$OS" == "Windows"* ]]; then
      drive="${1:1:1}"
      drive="${drive^^}"
      echo "$drive:${1:2}"
    else
      echo "$1"
    fi
  else
    echo "$1"
  fi
}

CUR_DIR="$(fmt_abs_path "$(realpath "$(pwd)")")"

# default values
NPM="pnpm"
WEBSITE_DIR="website"
# load .env file
source "$CUR_DIR/.env"

if ! is_abs_path "$WEBSITE_DIR"; then
  WEBSITE_DIR="$CUR_DIR/$WEBSITE_DIR"
fi
