from ctypes.wintypes import HENHMETAFILE
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

from pathlib import Path

class Header:
    GRECON = "GreCon"
    GRECON2 = "GreCon2"
    GRECOND = "GreConD"
    GRECON2_Q4 = "GreCon2 (Q4)"
    GRECON2_Q4_Q3 = "GreCon2 (Q4 $\cup$ Q3)"
    GRECON2_Q4_Q3_Q2 = "GreCon2 (Q4 $\cup$ Q3 $\cup$ Q2)"
    QUARTILE = "quartile"
    ITERATION = "iteration"

class Folder:
    GRAPHS = "graphs"
    RESULTS = "results"
    DATA = "data"
    DATASETS = "datasets"
    GRECON_VS_GRECOND_SIMILARITY = "grecon_vs_grecond_similarity"
    ALL_ALGORITHMS_COVERAGE_GRAPH = "grecon_greConD_grecon2_coverage_graph"
    GRECON2_GRECOND_COVERAGE_GRAPH  = "grecon2_greConD_coverage_graph"
    QUARTILE_COVERAGE_GRAPH = "quartile_coverage_graph"
    QUARTILES = "quartiles"

def count_column_names(file):
    data_file_delimiter = ';'
    largest_column_count = 0

    with open(file, 'r') as temp_f:
        lines = temp_f.readlines()

        for l in lines:
            column_count = len(l.split(data_file_delimiter)) + 1
            largest_column_count = column_count if largest_column_count < column_count else largest_column_count

    return [i for i in range(0, largest_column_count)]  

def generate_graphs(folder):
    POINTS_COUNT = 20

    current_path = Path('.')
    input_folder = current_path / Folder.RESULTS / folder
    output_folder = current_path / Folder.GRAPHS / folder

    output_folder.mkdir(exist_ok=True)

    for dataset_path in input_folder.rglob('*.csv'):
        df = pd.read_csv(str(dataset_path) , delimiter=";", index_col=0, header=None, names=count_column_names(str(dataset_path)))

        scatters = []
        algorithms = df.index
            
        fig, lines = plt.subplots()
            
        markers = {
            Header.GRECON  : ".",
            Header.GRECOND : ">",
            Header.GRECON2 : ">",
            Header.GRECON2_Q4 : "x",
            Header.GRECON2_Q4_Q3 : "+",
            Header.GRECON2_Q4_Q3_Q2 : "."
        }

        max_value = max(list(df.max()))

        for algorithm in algorithms:
            all_values = list(map(lambda x: x / max_value, filter(lambda x: x >= 0, df.loc[algorithm])))

            # y = list(map(lambda x: x / max_value, df.loc[algorithm][::20]))
            step = len(all_values) // POINTS_COUNT
            point_values = all_values[1::step]
            y = all_values if len(all_values) <= POINTS_COUNT else point_values

            x = list(range(1, len(all_values), step))
        
            scatters.append(plt.scatter(x, y, marker=markers[algorithm], 
                                        color='black'))
            
            plt.plot(list(range(0, len(all_values))), all_values, marker="", color='black', linewidth=0.5)
            #plt.plot(x, y, marker="", color='black', linewidth=0.5)
            

        plt.xlabel('Number of Factors')
        plt.ylabel('Coverage')
        plt.ylim(0, 1.1)
        plt.xlim(xmin=-0.5)

        plt.legend(scatters, algorithms,
                    loc='lower right')

        dataset_name = dataset_path.name.replace(".csv", ".eps")
        output_path = output_folder / dataset_name
        plt.tight_layout()
        plt.savefig(str(output_path), format='eps')
        plt.close()

def generate_similarity_graphs():
    current_path = Path('.')
    input_folder = current_path / Folder.RESULTS / Folder.GRECON_VS_GRECOND_SIMILARITY
    output_folder = current_path / Folder.GRAPHS / Folder.GRECON_VS_GRECOND_SIMILARITY
    output_folder.mkdir(exist_ok=True)

    for dataset_path in input_folder.rglob('*.csv'):
        df = pd.read_csv(str(dataset_path) , delimiter=";", index_col=0, header=None, names=count_column_names(str(dataset_path)))

        x = list(df.loc[Header.GRECON])
        y = list(df.loc[Header.GRECOND])
        
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
        plt.tight_layout()

        dataset_name = dataset_path.name.replace(".csv", ".eps")
        output_path = output_folder / dataset_name

        x = np.linspace(0, axis_max, 100)
        plt.plot(x, x, linestyle='dashed', color='gray', zorder=0)
        
        plt.savefig(str(output_path), format='eps')
        plt.close()


def generate_quartile_graphs():
    current_path = Path('.')
    input_folder = current_path / Folder.RESULTS / Folder.QUARTILES
    output_folder = current_path / Folder.GRAPHS / Folder.QUARTILES
    output_folder.mkdir(exist_ok=True)

    for dataset_path in input_folder.rglob('*.csv'):
        df = pd.read_csv(str(dataset_path) , delimiter=";", index_col=0, header=None, names=count_column_names(str(dataset_path)))

        x = list(df.loc[Header.ITERATION])
        y = list(df.loc[Header.QUARTILE])

        plt.scatter(x,y, marker='.', color="black")
        plt.tight_layout()
        plt.yticks([1, 2, 3, 4], ['Q1', 'Q2', 'Q3', 'Q4'])

        dataset_name = dataset_path.name.replace(".csv", ".eps")
        output_path = output_folder / dataset_name
        plt.savefig(str(output_path), format='eps')
        plt.close()

for folder in [Folder.ALL_ALGORITHMS_COVERAGE_GRAPH, Folder.GRECON2_GRECOND_COVERAGE_GRAPH, Folder.QUARTILE_COVERAGE_GRAPH]:
    generate_graphs(folder=folder)

generate_similarity_graphs()

generate_quartile_graphs()