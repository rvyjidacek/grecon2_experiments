import pandas as pd
import matplotlib.pyplot as plt

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

current_path = Path('.')
input_folder = current_path / Folder.RESULTS / Folder.GRECON2_GRECOND_COVERAGE_GRAPH
output_folder = current_path / Folder.GRAPHS / Folder.GRECON2_GRECOND_COVERAGE_GRAPH

output_folder.mkdir(exist_ok=True)

for dataset_path in input_folder.rglob('*.csv'):
    df = pd.read_csv(str(dataset_path) , delimiter=";", index_col=0, header=None)

    rows = df.values
    scatters = []
    algorithms = df.index
        
    fig, lines = plt.subplots()
        
    markers = {
        Algorithm.GRECON  : ">",
        Algorithm.GRECOND : "x",
        Algorithm.GRECON2 : "+"
    }

    for algorithm in algorithms:
        row_values = list(filter(lambda e: e > -1, df.loc[algorithm]))
        max_value = max(row_values)
        y = list(map(lambda x: x / max_value, row_values[::20]))
        x = list(range(0, len(row_values) - 1, 20))
    
        scatters.append(plt.scatter(x, y, marker=markers[algorithm], 
                                    color='black'))
        
        plt.plot(x, y, marker="", color='black', linewidth=0.5)
        

    plt.xlabel('Number of Factors')
    plt.ylabel('Coverage')
    plt.ylim(0, 1.1)
    plt.xlim(xmin=-0.5)

    plt.legend(scatters, algorithms,
                loc='lower right')

    dataset_name = dataset_path.name.replace(".csv", ".eps")
    output_path = output_folder / dataset_name
    plt.savefig(str(output_path), format='eps')
