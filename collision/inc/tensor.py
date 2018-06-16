#!/usr/bin/python3
# -*- coding: utf-8 -*-

import argparse
import collections

# Wyliczenie tensora momentu bezwładności.
# Dokumnetacja: https://pl.wikipedia.org/w/index.php?title=Tensor_momentu_bezw%C5%82adno%C5%9Bci&oldid=53013573


Vector4 = collections.namedtuple('Vector4', ['x', 'y', 'z', 'm'])


def make_tensor(data):
    ixx = 0
    iyy = 0
    izz = 0

    ixy = 0
    iyz = 0
    izx = 0

    for row in data:
        ixx += row.m * (row.y * row.y + row.z * row.z)
        iyy += row.m * (row.z * row.z + row.x * row.x)
        izz += row.m * (row.x * row.x + row.y * row.y)
        ixy -= row.m * row.x * row.y
        iyz -= row.m * row.y * row.z
        izx -= row.m * row.z * row.x

    return [[ixx, ixy, izx], [ixy, iyy, iyz], [izx, iyz, izz]]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--datafile', default='dane.dat')

    args = parser.parse_args()

    with open(args.datafile) as f:
        content = f.readlines()

    data = [Vector4(*[float(x) for x in row.strip().split()]) for row in content[1:]]

    tensor = make_tensor(data)

    print("Tensor matrix: ", *tensor, sep='\n')
    

if __name__ == "__main__":
    main()
