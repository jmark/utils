#!/usr/bin/env python3

import sys
import re
import csv
import argparse
import uncertainties as unc

pp = argparse.ArgumentParser(description = 'Uncertainties Handler')

def parse_column_or_pair(argstr):
    mm = re.match('(\d+):(\d+)', argstr)
    if mm:
        a,b = mm.groups()
        return (int(a),int(b))
    else:
        return int(argstr)

def process(col, row):
    if isinstance(col,int):
        return row[col]
    elif isinstance(col,tuple):
        return unc.ufloat(float(row[col[0]]), float(row[col[1]]))
    else:
        raise TypeError('%s is of wrong type!' % col)

pp.add_argument(
    '-d', '--delimiter',
    help='delimiter',
    type=str,
    default=',',
)

pp.add_argument(
    'columns',
    help='column pairs of value and its uncertainty',
    type=parse_column_or_pair,
    nargs='*'
)

ARGV = pp.parse_args()

for row in csv.reader(sys.stdin, delimiter=ARGV.delimiter, quotechar='|'):
    print(*[process(col, row) for col in ARGV.columns], sep=ARGV.delimiter)
