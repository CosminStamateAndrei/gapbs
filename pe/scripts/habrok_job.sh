#!/bin/bash
# Hábrók (RUG HPC) job: the full study on one exclusive compute node.
# From the repo root on a login node:
#     curl -fsSL -o pe/bench/stream.c https://www.cs.virginia.edu/stream/FTP/Code/stream.c
#     sbatch pe/scripts/habrok_job.sh
#     squeue -u $USER                      # wait for it; output in gapbs-<jobid>.out
# Results land in pe/results/habrok/; commit and push them from the login node.
#SBATCH --job-name=gapbs-bfs
#SBATCH --partition=regular
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --mem=120G
#SBATCH --time=02:30:00
#SBATCH --output=gapbs-%j.out

set -u
cd "${SLURM_SUBMIT_DIR:-.}"

module purge
# PAPI's EasyBuild module brings its own matching GCC; fall back to plain GCC
if module -t avail PAPI 2>&1 | grep -q '^PAPI'; then
  module load PAPI
else
  echo "no PAPI module; continuing without PAPI"
fi
command -v g++ > /dev/null && g++ --version | grep -q ' [1-9][0-9]\.' || module load GCC
module list 2>&1

echo "node $(hostname), $(nproc) CPUs, perf: $(command -v perf || echo missing)"
echo "perf_event_paranoid=$(cat /proc/sys/kernel/perf_event_paranoid)"
lscpu | head -20

MACHINE=habrok SKIP_APT=1 SET_SYS=0 bash pe/scripts/batch_all.sh
