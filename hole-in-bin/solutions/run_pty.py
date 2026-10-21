#!/usr/bin/env python3
"""
Helper: run a target under a pseudo-tty, write a payload to stdin, and
capture stdout/stderr. A pty is used so stdout stays line-buffered — the
"you won" strings that the challenges print with puts() flush before the
program is killed by SIGSEGV. On a regular pipe those messages sit in
libc's fully-buffered stdout and disappear when the process dies.

Usage: run_pty.py <binary> [<hex-payload>]
       (payload can also be piped on stdin; use --hex to interpret it as hex)
"""
import os, pty, sys, termios, binascii, argparse

def run(argv, payload, envextra=None):
    master, slave = pty.openpty()
    attr = termios.tcgetattr(slave)
    attr[3] &= ~(termios.ECHO | termios.ICANON | termios.ISIG)
    termios.tcsetattr(slave, termios.TCSANOW, attr)
    pid = os.fork()
    if pid == 0:
        os.close(master)
        os.dup2(slave, 0); os.dup2(slave, 1); os.dup2(slave, 2)
        os.close(slave)
        env = os.environ.copy()
        if envextra:
            env.update(envextra)
        os.execvpe(argv[0], argv, env)
    os.close(slave)
    if payload:
        os.write(master, payload)
    out = b''
    import select, time
    deadline = time.time() + 3.0
    while True:
        # If child already exited, drain then break.
        wpid, status = os.waitpid(pid, os.WNOHANG)
        r, _, _ = select.select([master], [], [], 0.1)
        if r:
            try:
                data = os.read(master, 4096)
            except OSError:
                data = b''
            if data:
                out += data
        if wpid != 0:
            # drain remaining
            try:
                while True:
                    r, _, _ = select.select([master], [], [], 0.05)
                    if not r: break
                    data = os.read(master, 4096)
                    if not data: break
                    out += data
            except OSError:
                pass
            break
        if time.time() > deadline:
            os.kill(pid, 9)
            _, status = os.waitpid(pid, 0)
            break
    return status, out

def parse_env(items):
    env = {}
    for it in items or []:
        k, _, v = it.partition('=')
        env[k] = v
    return env

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--hex', action='store_true', help='payload arg is hex')
    ap.add_argument('--stdin', action='store_true', help='read payload from stdin (bytes)')
    ap.add_argument('--stdin-hex', action='store_true', help='read hex payload from stdin')
    ap.add_argument('-e', '--env', action='append', help='extra env KEY=VAL')
    ap.add_argument('binary')
    ap.add_argument('args', nargs='*')
    ap.add_argument('--payload', default=None, help='literal payload bytes on command line (raw)')
    ap.add_argument('--hex-payload', default=None, help='hex payload bytes on command line')
    a = ap.parse_args()
    if a.stdin:
        payload = sys.stdin.buffer.read()
    elif a.stdin_hex:
        payload = binascii.unhexlify(sys.stdin.read().strip())
    elif a.hex_payload:
        payload = binascii.unhexlify(a.hex_payload)
    elif a.payload is not None:
        payload = a.payload.encode()
    else:
        payload = b''
    status, out = run([a.binary] + a.args, payload, parse_env(a.env))
    sys.stdout.buffer.write(out)
    if os.WIFEXITED(status):
        sys.stderr.write(f"[exit={os.WEXITSTATUS(status)}]\n")
    elif os.WIFSIGNALED(status):
        sys.stderr.write(f"[signal={os.WTERMSIG(status)}]\n")

if __name__ == '__main__':
    main()
