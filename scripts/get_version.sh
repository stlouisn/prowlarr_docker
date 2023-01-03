#!/usr/bin/env bash

set -euo pipefail

# Application version
APP_VERSION="$(curl -sSL --retry 5 --retry-delay 2 "https://prowlarr.servarr.com/v1/update/master/changes?" | jq -r '.[] | select ( .branch == "master" ) | .version' | sort -rn | head -n 1)"

# Export C_VERSION
echo "export C_VERSION=\""$APP_VERSION"\"" >> $BASH_ENV
