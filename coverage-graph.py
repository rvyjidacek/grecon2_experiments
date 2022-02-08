import pandas as pd
import matplotlib.pyplot as plt

from pathlib import Path

class Algorithm:
    GRECON = "GreCon"
    GRECON2 = "GreCon2"
    GRECOND = "GreConD"
    GRECON2_Q4 = "GreCon2 (Q4)"
    GRECON2_Q4_Q3 = "GreCon2 (Q4 $\cup$ Q3)"
    GRECON2_Q4_Q3_Q2 = "GreCon2 (Q4 $\cup$ Q3 $\cup$ Q2)"

class Folder:
    GRAPHS = "graphs"
    RESULTS = "results"
    DATA = "data"
    DATASETS = "datasets"
    GRECON_VS_GRECOND_SIMILARITY = "grecon_vs_grecond_similarity"
    ALL_ALGORITHMS_COVERAGE_GRAPH = "grecon_greConD_grecon2_coverage_graph"
    GRECON2_GRECOND_COVERAGE_GRAPH  = "grecon2_greConD_coverage_graph"
    QUARTILES_GRAPH = "quartiles_graph"

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
    current_path = Path('.')
    input_folder = current_path / Folder.RESULTS / folder
    output_folder = current_path / Folder.GRAPHS / folder

    output_folder.mkdir(exist_ok=True)

    for dataset_path in input_folder.rglob('*.csv'):
        df = pd.read_csv(str(dataset_path) , delimiter=";", index_col=0, header=None, names=count_column_names(str(dataset_path)))

        rows = df.values
        scatters = []
        algorithms = df.index
            
        fig, lines = plt.subplots()
            
        markers = {
            Algorithm.GRECON  : ">",
            Algorithm.GRECOND : "x",
            Algorithm.GRECON2 : "+",
            Algorithm.GRECON2_Q4 : ".",
            Algorithm.GRECON2_Q4_Q3 : "1",
            Algorithm.GRECON2_Q4_Q3_Q2 : "p"
        }

        max_value = max(list(df.max()))

        for algorithm in algorithms:
            y = list(map(lambda x: x / max_value, df.loc[algorithm][::20]))
            x = list(range(0, len(df.loc[algorithm]), 20))
        
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


for folder in [Folder.ALL_ALGORITHMS_COVERAGE_GRAPH, Folder.GRECON2_GRECOND_COVERAGE_GRAPH, Folder.QUARTILES_GRAPH]:
    generate_graphs(folder=folder)
