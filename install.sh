#!/usr/bin/env bash
# Usage: ./install.sh <hook-name>...   (a folder under hooks/)
set -euo pipefail
root=$(cd "$(dirname "$0")" && pwd)
hooks="$HOME/.config/omarchy/hooks"

[[ $# -gt 0 ]] || { echo "usage: $0 <hook-name>..."; ls "$root/hooks"; exit 1; }

for name in "$@"; do
  dir="$root/hooks/$name"
  [[ -d $dir ]] || { echo "no such hook: $name" >&2; exit 1; }
  # Hook folders hold scripts named NN-whatever.sh. Which hook(s) they attach to
  # is listed in the optional `events` file (default: theme-set).
  events=theme-set
  [[ -f $dir/events ]] && events=$(<"$dir/events")
  for script in "$dir"/*.sh; do
    for event in $events; do
      mkdir -p "$hooks/$event.d"
      ln -sfn "$script" "$hooks/$event.d/$(basename "$script")"
      echo "linked $event.d/$(basename "$script")"
    done
    "$script" || true
  done
done
