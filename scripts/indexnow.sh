#!/usr/bin/env bash
# Tell Bing (and other IndexNow engines) about new or updated pages.
# usage: scripts/indexnow.sh /blog/some-post/ [/other/path/ ...]
set -euo pipefail
cd "$(dirname "$0")/.."

HOST=debug5xx.pages.dev
KEY=$(cat .indexnow-key)

urls=""
for path in "$@"; do
  urls+="\"https://$HOST$path\","
done
[ -n "$urls" ] || { echo "usage: $0 /path/ [...]" >&2; exit 1; }

curl -s -o /dev/null -w 'IndexNow: %{http_code} (200/202 = accepted)\n' \
  -X POST https://api.indexnow.org/indexnow \
  -H 'Content-Type: application/json; charset=utf-8' \
  -d "{\"host\":\"$HOST\",\"key\":\"$KEY\",\"keyLocation\":\"https://$HOST/$KEY.txt\",\"urlList\":[${urls%,}]}"
