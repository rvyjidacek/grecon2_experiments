import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

from pathlib import Path

class Algorithm:
    GRECON = "GreCon"
    GRECON2 = "GreCon2"
    GRECOND = "GreConD"

class Folder:
    GRAPHS = "graphs"
    RESULTS = "results"
    DATA = "data"
    DATASETS = "datasets"
    GRECON_VS_GRECOND_SIMILARITY = "grecon_vs_grecond_similarity"
    ALL_ALGORITHMS_COVERAGE_GRAPH = "grecon_greConD_grecon2_coverage_graph"
    GRECON2_GRECOND_COVERAGE_GRAPH  = "grecon2_greConD_coverage_graph"   

def count_column_names(file):
    data_file_delimiter = ';'
    largest_column_count = 0

    with open(file, 'r') as temp_f:
        lines = temp_f.readlines()

        for l in lines:
            column_count = len(l.split(data_file_delimiter)) + 1
            largest_column_count = column_count if largest_column_count < column_count else largest_column_count

    return [i for i in range(0, largest_column_count)]  

current_path = Path('.')
input_folder = current_path / Folder.RESULTS / Folder.GRECON_VS_GRECOND_SIMILARITY
output_folder = current_path / Folder.GRAPHS / Folder.GRECON_VS_GRECOND_SIMILARITY
output_folder.mkdir(exist_ok=True)

for dataset_path in input_folder.rglob('*.csv'):
    df = pd.read_csv(str(dataset_path) , delimiter=";", index_col=0, header=None, names=count_column_names(str(dataset_path)))

    x = list(df.loc[Algorithm.GRECON])
    y = list(df.loc[Algorithm.GRECOND])
    
    axis_min = 0.7
    axis_max = max(max(x), max(y)) * 1.4
    
    plt.scatter(x, y, s=20, facecolors='none', edgecolors='black')

    plt.xlabel('GreCon')
    plt.ylabel('GreConD')
    plt.yscale("log")
    plt.ylim(axis_min, axis_max)
    plt.xlim(axis_min, axis_max)
    plt.xscale("log")
    plt.margins(0)

    dataset_name = dataset_path.name.replace(".csv", ".eps")
    output_path = output_folder / dataset_name

    x = np.linspace(0, axis_max, 100)
    plt.plot(x, x, linestyle='dashed', color='gray', zorder=0)
    plt.savefig(str(output_path), format='eps')


