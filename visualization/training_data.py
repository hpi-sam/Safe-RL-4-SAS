import glob
import os

import matplotlib.pyplot as plt
import pandas as pd

output_files = glob.glob('./outputs/simple_intersection/*')
output_file_name_arrays = [os.path.basename(file_path).split('_') for file_path in output_files]
models = set(f'{name_array[0]}_{name_array[1]}' for name_array in output_file_name_arrays)

# models = {'a2c_50'}
for model in models:
    model_files = sorted(glob.glob(f'./outputs/simple_intersection/{model}_*'),
                         key=lambda x: int(x.split('ep')[1].split('.csv')[0]))
    model_data_frame = pd.DataFrame()
    for index, file_path in enumerate(model_files):
        df = pd.read_csv(file_path)
        model_data_frame.loc[index, 'episode'] = index + 1
        model_data_frame.loc[index, 'mean_total_waiting_time'] = df['system_total_waiting_time'].mean()

    model_data_frame.plot.scatter(x='episode', y='mean_total_waiting_time')
    plt.title(model)
    plt.savefig(f'./visualization/training_plots/{model}.png')
    plt.show()
