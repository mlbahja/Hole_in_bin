# hole-in-bin — Solutions Index

Each exercise has a `solve.sh` in its own directory and a full writeup here.

---

## Quick reference

| Exercise | Vulnerability class | Success message | Solve script |
|----------|--------------------|--------------------|--------------|
| [ex00](ex00.md) | Stack BOF via `gets` — overwrite adjacent local | `you have changed the 'modified' variable` | `ex00/solve.sh` |
| [ex01](ex01.md) | Stack BOF via `strcpy(argv[1])` — set exact value | `you have correctly got the variable to the right value` | `ex01/solve.sh` |
| [ex02](ex02.md) | Stack BOF via `strcpy(getenv())` — set exact value | `you have correctly modified the variable` | `ex02/solve.sh` |
| [ex03](ex03.md) | Stack BOF via `gets` — overwrite function pointer | `code flow successfully changed` | `ex03/solve.sh` |
| [ex04](ex04.md) | ret2win — overwrite saved return address via `gets` | `code flow successfully changed` | `ex04/solve.sh` |
| [ex05](ex05.md) | Stack BOF via `sprintf(buf, argv[1])` — set exact value | `you have hit the target correctly :)` | `ex05/solve.sh` |
| [ex06](ex06.md) | Heap unlink exploit (dlmalloc) — GDB redirection on modern OS | `that wasn't too bad now, was it?` | `ex06/solve.sh` |
| [ex07](ex07.md) | Format-string `%n` write — single value | `you have modified the target :)` | `ex07/solve.sh` |
| [ex08](ex08.md) | Format-string `%hn` split write — large value | `you have modified the target :)` | `ex08/solve.sh` |
| [ex09](ex09.md) | Format-string GOT overwrite — redirect `exit@got` to `hello` | `code execution redirected! you win` | `ex09/solve.sh` |
| [ex10](ex10.md) | Heap BOF via `strcpy` — overwrite function pointer | `level passed` | `ex10/solve.sh` |
| [ex11](ex11.md) | Chained heap `strcpy` — arbitrary GOT write | `and we have a winner @ <time>` | `ex11/solve.sh` |

---

## How to run all solutions

```bash
cd /home/kali/hole-in-bin/hole-in-bin
for ex in ex00 ex01 ex02 ex03 ex04 ex05 ex06 ex07 ex08 ex09 ex10 ex11; do
    echo "=== $ex ==="
    bash "$ex/solve.sh" 2>/dev/null | grep -v '^\[\*\]' | grep -v '^$'
    echo ""
done
```

---

## Audit: capturing all proofs at once

```bash
cd /home/kali/hole-in-bin/hole-in-bin
mkdir -p audit_logs
for ex in ex00 ex01 ex02 ex03 ex04 ex05 ex06 ex07 ex08 ex09 ex10 ex11; do
    bash "$ex/solve.sh" 2>/dev/null > "audit_logs/${ex}_proof.txt"
    echo "$ex: $(tail -3 "audit_logs/${ex}_proof.txt" | grep -v '^\[\*\]' | grep -v '^$' | head -1)"
done
```

---

## Helper scripts

| File | Purpose |
|------|---------|
| `run_pty.py` | Runs a binary under a pseudo-tty so `puts()` flushes before `_exit()` kills the process (needed for ex04, ex09) |
| `ex06_solve.py` | Original automated attempt at the full dlmalloc unlink exploit (blocked by modern OS mitigations) |
