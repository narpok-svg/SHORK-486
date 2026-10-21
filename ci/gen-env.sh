#!/usr/bin/env bash
# Generate a non-interactive SHORK 486 build configuration (.env) that is
# equivalent to picking "SHORK 486" -> "default" in the Build Configurator.
#
# The configurator is a dialog TUI, so this pulls the constants and shell
# functions out of config.sh and calls the same preset function it would.
#
# Usage: gen-env.sh path/to/shork-486/config.sh [output dir]
set -euo pipefail

cfg="${1:?usage: gen-env.sh path/to/config.sh [output dir]}"
outdir="${2:-.}"
cfg="$(cd "$(dirname "$cfg")" && pwd)/$(basename "$cfg")"

parts="$(mktemp)"
trap 'rm -f "$parts"' EXIT

# Default values and minimum sizes
sed -n '/^CUSTOM_DEF_SWAP=/,/^ENABLE_ZSWAP=false/p' "$cfg" > "$parts"
# Every shell function definition (set_*_vars, save_env, ...)
awk '/^[A-Za-z_][A-Za-z0-9_]*\(\)$/ {infn=1} infn {print} infn && /^}$/ {infn=0; print ""}' "$cfg" >> "$parts"

mkdir -p "$outdir"
cd "$outdir"
# shellcheck disable=SC1090
source "$parts"

# Same selections config.sh records for SHORK 486 + Default
set_default_vars
DIST="SHORK 486"
ID="shork-486"
BUILD_TYPE="default"
HOSTNAME="shork-486"
TARGET_ARCH="486DX"
TARGET_DISK=120
TARGET_SWAP=8
ENABLE_BOOT_PART=false
ENABLE_DYN_SWAP=true
ENABLE_MULTIUSER_REAL=false
ENABLE_SERIAL_CON=false
SET_KEYMAP="qwerty_en_us"

save_env >/dev/null

echo "Wrote ${outdir}/.env"
grep -E '^(DIST|ID|BUILD_TYPE|TARGET_ARCH|TARGET_DISK|TARGET_SWAP)=' .env
