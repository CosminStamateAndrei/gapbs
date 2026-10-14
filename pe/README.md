# Performance study of GAPBS BFS (Group 1)

Sergiu Macra, Cosmin Stamate. RUG Performance Engineering (WMCS045-05), 2026.

Everything for the study lives in `pe/`; the GAPBS code is changed only through
compile-time switches in `src/pe_opts.h`. **A plain `make` builds unmodified upstream
behaviour.**

## Code changes (all off by default)

| Switch | Where | Purpose |
|---|---|---|
| `-DUSE_PAPI` (+ `-lpapi`) | `src/bfs.cc` | PAPI high-level regions inside every parallel region: `InitParent`, `TDStep`, `BUStep`, `QueueToBitmap`, `BitmapToQueue` |
| `-DOMP_RUNTIME_SCHED` | `src/bfs.cc` | `schedule(runtime)` for TDStep and BUStep, so `OMP_SCHEDULE` selects the schedule |
| `-DPF_DIST=n` | `src/bfs.cc` | software prefetch of `parent[v]` n neighbours ahead in TDStep |
| `-DUSE_HUGEPAGES` | `pvector.h`, `reader.h`, `graph.h` | `madvise(MADV_HUGEPAGE)` on large arrays before first touch (Linux) |
| `-DPE_THP_REPORT` | `src/bfs.cc` | print `Rss` and `AnonHugePages` at the end of `main` |
| `-DRELABEL` | `src/bfs.cc` | relabel vertices by decreasing degree before the BFS |
| `-DBFS_ALPHA=a -DBFS_BETA=b` | `src/bfs.cc` | direction-switch thresholds (defaults 15 / 18) |

To make the PAPI regions count every thread, each `#pragma omp parallel for` was split
into `#pragma omp parallel { region; #pragma omp for ... }`, which has the same semantics.

**Correctness constraint found:** `BUStep` sets bits of the shared `next` bitmap without
atomics. It is only correct when every thread's block of vertices starts on a 64-bit word,
which is why upstream uses `schedule(dynamic, 1024)`. Schedules with chunks that are not a
multiple of 64 (`dynamic,100`, `guided`) fail verification; see `sched_correctness.txt`.

## Scripts

| Script | What it does |
|---|---|
| `scripts/build_variants.sh` | builds all variants into `pe/bin/`, plus converter, microbench, STREAM; GCC vectorisation reports |
| `scripts/run_bfs.sh BIN VARIANT [REPS] [TRIALS]` | 1 discarded warm-up run, then REPS processes x TRIALS trials, one CSV row per trial |
| `scripts/batch_all.sh` | complete x86 study in one native Linux session (≈30–45 min) |
| `scripts/mac_all.sh` | complete Apple Silicon study (no pinning, no perf/PAPI on macOS) |
| `scripts/analyze.py` | summaries, counter tables, `key_numbers.md`, and figures in `pe/plots/<machine>/` |
| `bench/microbench.c` | timer resolution, pointer-chase latency, known-answer tests for counter validation |

Measurement method: trials 1–4 of every process are warm-up and are dropped. We report the
median and interquartile range in ms per trial, and GTEPS = undirected edges / median time.

## x86: native Linux session (Cosmin)

Before rebooting: commit and push everything from WSL, and create a GitHub token with
`repo` scope (Settings → Developer settings → Fine-grained token → contents: read/write).

1. Boot the Ubuntu 24.04 USB → "Try Ubuntu". Connect to Wi-Fi and plug in the charger.
2. Open a terminal:
   ```
   sudo -i
   git clone https://github.com/CosminStamateAndrei/gapbs.git && cd gapbs
   GH_TOKEN=<token> bash pe/scripts/batch_all.sh 2>&1 | tee /root/batch.out
   ```
3. Don't use the machine while it runs. At the end, check the "Failed steps" line and that the push
   succeeded. If the push fails, the tarball is in `/root/` (upload it with Firefox).

Smoke test in WSL (no hardware counters there): `QUICK=1 bash pe/scripts/batch_all.sh`.

## Mac (Sergiu)

```
brew install gcc
git clone https://github.com/CosminStamateAndrei/gapbs.git && cd gapbs
CXX=g++-15 CC=gcc-15 bash pe/scripts/mac_all.sh     # use the version brew installed
```
Close other apps, use the charger, and keep Low Power Mode off.

Instruments (second tool, hardware counters):
1. `xcrun xctrace record --template 'Time Profiler' --output pe/results/mac/bfs_time.trace --launch -- pe/bin/bfs_base -f kron20.sg -n 64`
   then open the trace and export the call tree (heaviest functions: `TDStep`, `BUStep`, ...).
2. In Instruments choose **CPU Counters**. In the recording options, add events for cycles, instructions,
   L1D load misses, and branch mispredicts. Choose `pe/bin/bfs_base` as the target, with arguments
   `-f kron20.sg -n 64`, and record. Then record the same with `-n 0` (graph load only) and subtract.
3. Known-answer check: record `pe/bin/microbench alu 1000000000` and `... alu 2000000000`. The
   instruction difference divided by 1e9 must equal the number of instructions in the loop of
   `known_answer_alu_disasm.txt`. Also record `pe/bin/microbench chase 1048576 10000000` and
   `... 20000000`: the L1D miss difference should be about 1e7.

Put screenshots and exported numbers in `pe/results/mac/instruments/`, then push.

## Analysis (either of you, after results are pushed)

```
git pull
python3 pe/scripts/analyze.py          # needs pandas + matplotlib
```
