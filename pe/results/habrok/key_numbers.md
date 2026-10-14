# Key numbers: habrok

Warm-up trials dropped per process: 5

## Baseline (kron20)

| core set | threads | median ms | IQR ms | GTEPS |
|---|---|---|---|---|
| all | 128 | 2.85 | 1.43 | 5.51 |

STREAM all: Copy 407.6 GB/s, Scale 300.8 GB/s, Add 339.6 GB/s, Triad 327.0 GB/s
STREAM P: Copy 313.3 GB/s, Scale 236.1 GB/s, Add 254.8 GB/s, Triad 250.2 GB/s
STREAM 1T: Copy 45.4 GB/s, Scale 34.7 GB/s, Add 34.7 GB/s, Triad 34.7 GB/s

## Load latency (pointer chase, ns)

P-core: 16KB 1.3, 32KB 1.4, 64KB 3.9, 128KB 3.5, 256KB 4.2, 512KB 9.0, 1024KB 13.9, 2048KB 12.1, 4096KB 13.0, 8192KB 13.4, 16384KB 13.6, 32768KB 15.2, 65536KB 64.2, 131072KB 85.2, 262144KB 91.8, 524288KB 96.9, 1048576KB 98.7

## timer_resolution.txt
```
res CLOCK_MONOTONIC ns 1
res CLOCK_PROCESS_CPUTIME_ID ns 1
clock_gettime overhead ns 34.2 (sink 1)
```

## sched_correctness.txt
```
static 8/8 PASS
static,1000 0/8 PASS
dynamic,100 0/8 PASS
guided 0/8 PASS
dynamic,64 8/8 PASS
dynamic,1024 8/8 PASS
```

## thp_usage.txt
```
system THP mode: always
always/base: THP Rss:              144492 kB THP AnonHugePages:    129024 kB 
always/huge: THP Rss:              142648 kB THP AnonHugePages:    126976 kB
```

## verify.txt
```
bfs_a15b18 PASS
bfs_a15b36 PASS
bfs_a15b9 PASS
bfs_a30b18 PASS
bfs_a30b36 PASS
bfs_a30b9 PASS
bfs_a5b18 PASS
bfs_a5b36 PASS
bfs_a5b9 PASS
bfs_base PASS
bfs_huge PASS
bfs_native PASS
bfs_O0 PASS
bfs_O1 PASS
bfs_O2 PASS
bfs_O3 PASS
bfs_pf16 PASS
bfs_pf2 PASS
bfs_pf32 PASS
bfs_pf4 PASS
bfs_pf8 PASS
bfs_pg PASS
bfs_relabel PASS
bfs_sched PASS
bfs_thp PASS
```

## Timer cross-check (one process, NTR trials)

| rep | GAPBS read+trials s | perf duration_time s | perf task-clock s | /usr/bin/time elapsed s |
|---|---|---|---|---|
| 1 | 0.000 | nan | nan | n/a |
| 2 | 0.000 | nan | nan | n/a |
| 3 | 0.000 | nan | nan | n/a |
| 4 | 0.000 | nan | nan | n/a |
| 5 | 0.000 | nan | nan | n/a |
