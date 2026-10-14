# Speaker notes (20 min + 5 min Q&A)

Split: **Cosmin** slides 1–9 (application, systems, method, analysis, ~10 min),
**Sergiu** slides 10–17 (model, optimisations, conclusions, ~10 min). About 70 s per slide.

| # | Slide | Who | Time | Key message |
|---|---|---|---|---|
| 1 | Title | C | 0:20 | Group 1, GAPBS BFS, laptop + Hábrók |
| 2 | Overview | C | 0:20 | Analysis → model → optimisation, as the assignment asks |
| 3 | Application | C | 1:30 | Top-down vs bottom-up; **only 4.7 % of edges are examined**, so TEPS overstates the work about 20× |
| 4 | Systems | C | 1:00 | WSL2 hides counters; Hábrók had no perf/PAPI, so we built PAPI and wrote pecount |
| 5 | Method | C | 1:00 | Medians + IQR, drop 5 warm-up trials, significant = beyond both IQRs, verify everything |
| 6 | Tool validation | C | 1:30 | Tools agree within 1–10 %; known answers exact; gprof fails on OpenMP; multiplexing breaks scaling |
| 7 | Data race | C | 1:00 | Non-atomic bitmap writes; chunk size must be a multiple of 64 |
| 8 | Hotspots | C | 1:30 | 50 % barrier spin (laptop); BUStep 78 % of cycles; IPC ≈ 1 → memory-bound |
| 9 | Scaling | C | 1:00 | Hábrók best at 48–64 bound threads; slower at 128. "Why only 3× faster?" → hand over |
| 10 | Model | S | 1:30 | Why not roofline/ECM; T_bw and T_lat with measured Q, N_rand, B, L, MLP |
| 11 | Model vs measurement | S | 1:30 | Three regimes: latency → bandwidth → synchronisation/NUMA |
| 12 | Optimisations overview | S | 1:00 | Significant vs within noise |
| 13 | Relabelling | S | 1:30 | Fewer edges examined (−35/−48 %) + locality; one-off cost |
| 14 | Threads + NUMA | S | 1:30 | Socket-local threads 2.1×; first touch 2.1× with spread binding |
| 15 | What didn't help | S | 1:00 | Each null result was predicted by analysis/model |
| 16 | Conclusions | S | 1:00 | Memory + synchronisation; three wins; next: fuse parallel regions |
| 17 | Questions | both | | |

Likely questions:
- *Why WSL2 numbers at all?* Timing and sampling are valid; we state the variance and use IQR-based significance.
- *Is relabelling fair?* Its cost is excluded and reported separately (0.46 s, amortised after ~90 searches); sources differ.
- *Why not more threads on Hábrók?* Barrier cost grows with threads, and cross-socket coherence traffic appears; the model isolates this.
- *Why does the laptop beat its bandwidth bound?* `parent` (4 MB) and the bitmaps stay in the 24 MB L3.
