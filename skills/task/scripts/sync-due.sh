#!/usr/bin/env bash
# Print a reminder when a recorded sync is due.
set -eu
if { [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; } || ! [[ $2 =~ ^[1-9][0-9]{0,8}$ ]]; then
  echo 'usage: sync-due.sh <timestamp-file> <max-age-seconds> <command-label> [<message>]' >&2
  exit 2
fi
last=
if [ -f "$1" ]; then
  read -r last < "$1" || :
fi
now=$(date +%s)
if ! [[ $last =~ ^[1-9][0-9]{0,10}$ ]] || [ "$last" -gt "$now" ]; then
  message="No recent workspace sync is recorded. Run $3 before starting work."
elif [ "$((now - last))" -ge "$2" ]; then
  message="Workspace sync is due (last sync $(((now - last) / 3600)) h ago). Run $3 before starting work."
else
  exit 0
fi
printf '%s\n' "${4-$message}"
