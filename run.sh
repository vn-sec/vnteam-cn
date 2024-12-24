#!/bin/bash
# The program should be run in the root directory of the project
set -e

NPM="pnpm"
source ".github/basic-env.sh"
# functions: is_abs_path, fmt_abs_path
# var: CUR_DIR (absolute path)
# env: NPM, WEBSITE_DIR (absolute path)

opt_setup=false
opt_watch=false
opt_apply=true
opt_only_apply=false
opt_clean=false
ARGS=()

# Print functions

ANSI_CYAN="$(echo -en '\033[0;36m')"
ANSI_MAGENTA="$(echo -en '\033[0;35m')"
ANSI_RED="$(echo -en '\033[0;31m')"
ANSI_RESET="$(echo -en '\033[0m')"
prevent_next_print_newline=true
PRINT_PREFIX=""
function add_print_prefix() {
  PRINT_PREFIX+="- "
}
function pop_print_prefix() {
  PRINT_PREFIX="${PRINT_PREFIX::-2}"
}
function prevent_next_newline() {
  prevent_next_print_newline=true
}
function print() {
  if [ -z "$1" ]; then
    [ "$prevent_next_print_newline" == false ] && echo
  else
    echo "${ANSI_CYAN}$PRINT_PREFIX$1${ANSI_RESET}"
  fi
  prevent_next_print_newline=false
}

# Ensure pnpm

if ! "$NPM" help 2>/dev/null | grep -q "Usage: pnpm" ; then
  print "${ANSI_RED}Error: ${ANSI_RESET}pnpm is required to run this script"
  print
  prevent_next_newline
  exit 1
fi

# Arguments parsing

while [ "$#" -gt 0 ]; do
  case "$1" in
    --setup)
      opt_setup=true ;;

    --skip-apply)
      opt_apply=false ;;

    --only-apply)
      opt_only_apply=true
      ARGS=()
      break ;;

    --watch)
      opt_watch=true ;;

    --clean)
      opt_clean=true ;;

    --outDir)
      ARGS+=("$1")
      shift
      # if no argument, skip
      if [ -z "$1" ]; then
        shift
        continue
      fi
      # if starts with "-", it's an option
      if [[ "$1" == -* ]]; then
        ARGS+=("$1")
        continue
      fi
      # modify the path
      if is_abs_path "$1"; then
        ARGS+=("$1")
      else
        ARGS+=("$CUR_DIR/$1")
      fi ;;

    --outDir=*)
      out_dir="${1#*=}"
      # modify the path
      if ! is_abs_path "$out_dir"; then
        out_dir="$CUR_DIR/$out_dir"
      fi
      ARGS+=("--outDir=\"$out_dir\"")
      echo "Output directory: $out_dir"
      unset out_dir ;;

    *)
      ARGS+=("$1") ;;

  esac
  shift
done

# Functions

function npm_program() {
  "$NPM" --prefix "$CUR_DIR" "$@"
}

function npm_website() {
  "$NPM" --prefix "$WEBSITE_DIR" "$@"
}

function apply() {
  print && print "Applying your modifications"
  add_print_prefix

  bash "$CUR_DIR/apply.sh"

  pop_print_prefix
}

function clean() {
  print && print "Cleaning up"
  add_print_prefix

  npm_website run clean
  cd "$WEBSITE_DIR"
  git reset --hard
  cd "$CUR_DIR"

  pop_print_prefix
}

function setup() {
  print && print "Setting up the website"
  add_print_prefix

  print "Preparing the submodules"
  git submodule update --init

  if [ "$opt_apply" == true ]; then
    prevent_next_newline
    add_print_prefix

    apply

    pop_print_prefix
  fi

  print "Installing dependencies"
  npm_website install

  pop_print_prefix
}

# Main

# auto setup if node_modules is missing
if [ ! -d "$WEBSITE_DIR/node_modules" ]; then
  opt_setup=true
fi

# empty arguments
if [ "${#ARGS[@]}" -eq 0 ]; then
  if [ "$opt_setup" == true ]; then
    setup
    exit 0
  elif [ "$opt_only_apply" == true ]; then
    apply
    exit 0
  elif [ "$opt_clean" == true ]; then
    clean
    exit 0
  else
    npm_website run
    exit 0
  fi
fi

if [ "$opt_setup" == true ]; then
  # --setup
  setup
elif [ "$opt_apply" == true ]; then
  # --apply (only when `--setup` is not set, for `setup` already runs `apply`)
  apply
fi

# --watch
if [ "$opt_watch" == true ]; then
  print && print "Watching for file changes"
  add_print_prefix

  cd "$CUR_DIR" && node .github/watch.mjs "$WEBSITE_DIR" &

  pop_print_prefix
fi

# website command
print && print "Start running the website command"
NPM_DISPLAY="$NPM"
[[ "$NPM" == *" "* ]] && NPM_DISPLAY="$(echo "$NPM" | sed 's/"/\\"/g' | sed 's/^/"/' | sed 's/$/"/')"
ARG_DISPLAY=""
for arg in "${ARGS[@]}"; do
  if [[ "$arg" == *" "* ]] || [[ "$arg" == *"'"* ]] || [[ "$arg" == *'"'* ]]; then
    ARG_DISPLAY+=" \"$(echo "$arg" | sed 's/"/\\"/g')\""
  else
    ARG_DISPLAY+=" $arg"
  fi
done
print "${ANSI_MAGENTA}> $NPM_DISPLAY run${ARG_DISPLAY}${ANSI_RESET}"
add_print_prefix

npm_website run "${ARGS[@]}"

pop_print_prefix

# --clean
if [ "$opt_clean" == true ]; then
  clean
fi