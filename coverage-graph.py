## COVERAGE GRAPH

import matplotlib.pyplot as plt
import csv
import numpy as np
import sys
from os import listdir
from os.path import isfile, join
from pathlib import Path
    
def generate_graph(x_padding, y_padding, step, labels, input_file, output_file):
    rows = []
    max_value = 0
    index = 0
    scatters = []
    algorithms = []
        
    with open(input_file, 'r') as csvfile:
        plots = csv.reader(csvfile, delimiter=';')
        
        for row in plots:
            algorithms.append(row[0])
            filtered_row = list(map(lambda x: float(x), list(filter(lambda x: x != "", row[1:]))))
            rows.append(filtered_row)
            row_max = float(max(filtered_row))
            max_value = row_max if row_max > max_value else max_value
    
    fig, lines = plt.subplots()
    


    for row in rows:
        x = []
        y = []
        
        for j in range(1, len(row) - 1, step):
            y.append(float(row[j]) / max_value)
            x.append(float(j))
        
        scatters.append(plt.scatter(x, y, marker=['>', 'x', '+', '.', 'o', 'v', '2', 's', '<', 'p', 'P', 'X', 'd'][index], 
                                    color='black'))
        
        x = []
        y = []
        
        for j in range(0, len(row) - 1):
            y.append(float(row[j]) / max_value)
            x.append(float(j))
        
        plt.plot(x, y, marker="", color='black', linewidth=0.5)
        
        index += 1


        # row_max = float(row[-2] if row[-1] == "" else row[-1])
        # x = []
        # y = []
        
        # for j in range(1, len(row) - 1):
        #     y.append(float(row[j]) / row_max)
        #     x.append(float(j - 1))
        
        # marker_skip = int(len(x) / 15)
        # # Experssion plt.plot returns tuple and I want only first item.
        # line, = plt.plot(x[1:], y[1:], marker=markers[index], color='black', linewidth=0.5, markevery=marker_skip)
        # lines.append(line)
        # plt.plot([0, x[1]], [0, y[1]], marker='', color='black', linewidth=0.5)
        # index += 1

    plt.xlabel('Number of Factors')
    plt.ylabel('Coverage')
    plt.ylim(0, 1.1)
    plt.xlim(xmin=-0.5)
    
    #plt.tight_layout()
    plt.legend(scatters, labels,
               loc='lower right')
    plt.savefig(output_file, format='eps')
    plt.close()

mypath = "/Users/romanvyjidacek/repositories/kmi/grecon2_experiments/results/grecon_greConD_coverage_cmp"
output = "/Users/romanvyjidacek/repositories/kmi/grecon2_experiments/graphs/grecon_greConD_coverage_cmp"

Path(output).mkdir(parents=True, exist_ok=True)

files = [f for f in listdir(mypath) if isfile(join(mypath, f))]

for file in files:
    generate_graph(10,5000,10,("GreCon", "GreConD"),'{}/{}'.format(mypath, file), '{}/{}.eps'.format(output, file))

 
