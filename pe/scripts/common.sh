# Shared helpers for the pe/ scripts. Source it; works with bash 3.2 (macOS) and bash 5.
# Sets: ROOT, MACHINE, OUT (results dir), RAW (raw logs), BIN, GRAPH, OS

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
OS=$(uname -s)
if [ -z "${MACHINE:-}" ]; then
  if [ "$OS" = Darwin ]; then MACHINE=mac; else MACHINE=x86; fi
fi
OUT=${OUT_DIR:-$ROOT/pe/results/$MACHINE}
RAW=$OUT/raw
BIN=$ROOT/pe/bin
GRAPH=${GRAPH:-$ROOT/kron20.sg}
mkdir -p "$OUT" "$RAW" "$BIN"

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$OUT/batch.log"; }

# Number of logical CPUs this process may use (respects Slurm/cgroup affinity)
ncpu() { if command -v nproc >/dev/null 2>&1; then nproc; else sysctl -n hw.ncpu; fi; }

# "0-3,8,10-11" -> 7
cpulist_count() {
  echo "$1" | tr ',' '\n' | awk -F- 'NF==2{n+=$2-$1+1; next} NF==1&&$1!=""{n++} END{print n+0}'
}

# P-core / E-core CPU lists on Intel hybrid (empty when not available)
pcores() { cat /sys/devices/cpu_core/cpus 2>/dev/null || true; }
ecores() { cat /sys/devices/cpu_atom/cpus 2>/dev/null || true; }

# Physical core count (Linux: lscpu; macOS: sysctl)
nphys() {
  if [ "$OS" = Darwin ]; then sysctl -n hw.physicalcpu
  else lscpu -p=CORE 2>/dev/null | grep -v '^#' | sort -u | wc -l | tr -d ' '; fi
}

FAILED_STEPS=""
# step NAME command...  -> runs, logs, never aborts the batch
step() {
  local name=$1; shift
  log "=== START $name"
  local t0; t0=$(date +%s)
  if "$@" >> "$RAW/step_$name.log" 2>&1; then
    log "=== OK    $name ($(( $(date +%s) - t0 )) s)"
  else
    log "=== FAIL  $name (see raw/step_$name.log)"
    FAILED_STEPS="$FAILED_STEPS $name"
  fi
}
