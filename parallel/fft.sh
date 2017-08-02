#!/bin/bash

mkdir -p pickle log

NBATCH="${NBATCH:-8}"
NPROCS="${NPROCS:-2}"

parallel \
    -N "$NBATCH" sbatch -o "'log/{#}.log'" -e "'log/{#}.log'" -J "'fft {#}'" \
    $HOME/turbubox/setup/sbatch-devel.sh \
    $HOME/turbubox/tools/bin/powerspectrum.py --destdir pickle/ --skip --parallel "$NPROCS" '{}' ::: "$@"
