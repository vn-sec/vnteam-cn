#!/bin/bash
# The program should be run in the root directory of the project

source ".github/basic-env.sh"
# functions: is_abs_path, fmt_abs_path
# var: CUR_DIR (absolute path)
# env: NPM, WEBSITE_DIR (absolute path)

function cp_file() {
  if [ "$1" == "--check" ]; then
    shift
    if [ ! -f "$1" ]; then
      echo "File not found: $1"
      return 0
    fi
  fi
  rm -f "$WEBSITE_DIR/$1"
  cp "$1" -t "$WEBSITE_DIR/"
}

function cp_dir() {
  if [ "$1" == "--check" ]; then
    shift
    if [ ! -d "$1" ]; then
      echo "Directory not found: $1"
      return 0
    fi
  fi
  rm -rf "$WEBSITE_DIR/$1"
  cp -r "$1" -t "$WEBSITE_DIR/"
}

cp_file --check site-config{.yml,.yaml,.json}
cp_dir config
