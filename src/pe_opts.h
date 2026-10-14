// Performance-engineering switches for the BFS study (Group 1).
// Everything here is off by default, so a plain `make` builds upstream behaviour.
//
//   -DUSE_PAPI          PAPI high-level regions around each BFS kernel
//                       (link with -lpapi; set PAPI_EVENTS at run time)
//   -DUSE_HUGEPAGES     madvise(MADV_HUGEPAGE) on large arrays (Linux only)
//   -DPE_THP_REPORT     print AnonHugePages of this process at exit (Linux only)
//   -DOMP_RUNTIME_SCHED TDStep/BUStep loops use schedule(runtime) -> OMP_SCHEDULE
//   -DPF_DIST=<n>       software prefetch distance in TDStep (0 = off)

#ifndef PE_OPTS_H_
#define PE_OPTS_H_

#include <cstddef>
#include <cstdint>

#ifndef PF_DIST
#define PF_DIST 0
#endif


// ---- PAPI regions ---------------------------------------------------------
// Must be called by every thread inside a parallel region, because the PAPI
// high-level API only counts the calling thread.
#ifdef USE_PAPI
#include <papi.h>
#define PE_REGION_BEGIN(name) PAPI_hl_region_begin(name)
#define PE_REGION_END(name)   PAPI_hl_region_end(name)
#else
#define PE_REGION_BEGIN(name) ((void)0)
#define PE_REGION_END(name)   ((void)0)
#endif


// ---- Transparent huge pages -----------------------------------------------
// Call right after allocating and before the memory is first touched, so the
// first page faults can already be served with 2 MB pages.
#if defined(USE_HUGEPAGES) && defined(__linux__)
#include <sys/mman.h>
inline void HugeAdvise(void *ptr, size_t bytes) {
  const uintptr_t kHuge = 2u << 20;
  if (bytes < kHuge)
    return;
  uintptr_t begin = (reinterpret_cast<uintptr_t>(ptr) + kHuge - 1) & ~(kHuge - 1);
  uintptr_t end = (reinterpret_cast<uintptr_t>(ptr) + bytes) & ~(kHuge - 1);
  if (end > begin)
    madvise(reinterpret_cast<void*>(begin), end - begin, MADV_HUGEPAGE);
}
#else
inline void HugeAdvise(void *, size_t) {}
#endif


// Call while the graph is still alive (end of main); no-op unless enabled.
#if defined(PE_THP_REPORT) && defined(__linux__)
#include <fstream>
#include <iostream>
#include <string>
inline void PEReportTHP() {
  std::ifstream f("/proc/self/smaps_rollup");
  std::string line;
  while (std::getline(f, line))
    if (line.rfind("AnonHugePages:", 0) == 0 || line.rfind("Rss:", 0) == 0)
      std::cout << "THP " << line << std::endl;
}
#else
inline void PEReportTHP() {}
#endif

#endif  // PE_OPTS_H_
