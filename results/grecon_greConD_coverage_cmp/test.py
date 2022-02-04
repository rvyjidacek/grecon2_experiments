#!/usr/bin/env python3

import csv

algorithms = []
rows = []
max_value = 0

with open("americas_large", 'r') as csvfile:
    plots = csv.reader(csvfile, delimiter=';')
    
    for row in plots:
        algorithms.append(row[0])
        filtered_row = list(map(lambda x: float(x), list(filter(lambda x: x != "", row[1:]))))
        rows.append(filtered_row)
        row_max = float(max(filtered_row))
        max_value = row_max if row_max > max_value else max_value