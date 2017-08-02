#!/bin/bash

mkdir -p log cache png

NBATCH="${NBATCH:-8}"
NPROCS="${NPROCS:-2}"
NFILES="$(echo "$@" | wc -w)"
CRANGE="'cdens=(-1.0,1.0), cekin=(0.3,3.0), cmach=(0.5,1.5), cvort=(-12,-7)'"

parallel -N "$NBATCH" sbatch -o "'log/{#}.log'" -e "'log/{#}.log'" -J "'plot flexi {#}'" \
    $HOME/turbubox/setup/sbatch-devel.sh $HOME/turbubox/plot/dens-ekin-mach-vort.py \
        --destdir png/ --cachedir cache/ --parallel "$NPROCS" --ntasks $NFILES \
        --crange "$CRANGE" '{}' ::: "$@"
