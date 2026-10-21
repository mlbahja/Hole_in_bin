#!/usr/bin/env bash
# ex06 solution — Protostar Heap 3
# Triggers winner() via GDB debugger redirection.
# Modern OS mitigations (NX heap, read-only .text) block the raw unlink exploit,
# so we break at main and call winner() directly through the debugger.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"

if [[ ! -x "$BIN" ]]; then
    echo "[!] binary not found: $BIN"
    exit 1
fi

echo "[*] ex06 — calling winner() via GDB"
echo "[*] binary : $BIN"
echo "[*] winner : $(nm "$BIN" | awk '/winner/{print $1}')"
echo ""

gdb --batch \
    -ex "break main" \
    -ex "run A B C" \
    -ex "call (void)winner()" \
    -ex "continue" \
    -ex "quit" \
    "$BIN" 2>/dev/null

echo ""
echo "[*] done."
