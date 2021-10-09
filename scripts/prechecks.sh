#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "Usage: $0 \$RUNNER"
    exit 1
else
    runner=$1
fi

# Validates that application available on host. Returns error if not.
cmd_exists() {
  	hash $1 > /dev/null 2>&1 || \
		(echo "ERROR: '$1' must be installed and available on your PATH."; exit 1)
}

# Compares required and current cmd versions.
check_version() {
    app=$1
    required=$2
    current=$3
    if [ "$current" != "$required" ]; then echo "Bad $app version '$current'; required '$required'" && exit 1; fi
}

# Checks that app cmd exists and validates version.
check_app() {
    cmd_exists $1
    check_version "$1" "$2" "$3"
}

case $runner in
  "local")
    check_app "terraform" "v1.0.8" "$(terraform -v | head -1 | awk '{print $2}')"
    check_app "ansible" "2.9.9" "$(ansible --version | head -1 | awk '{print $2}')"
    ;;

  "docker")
    cmd_exists "docker"
    ;;

  *)
    echo "Unexpected runner type '$runner'"
    exit 1
    ;;
esac
