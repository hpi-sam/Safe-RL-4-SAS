import glob
import xml.etree.ElementTree as ET

import pandas as pd

model = 'a2c'
shield = '0'
speed = '100'

folders = glob.glob(f'./results_safe_rl_report/*')

for experiment in folders:

    statistics_files = glob.glob(f'{experiment}/*.statistics.xml')
    experiment_data = []

    for statistics_file in statistics_files:
        data = {'index': int(str(statistics_file.split('/')[-1].split('.')[0]))}

        collision_file = statistics_file.replace('statistics.xml', 'collision.xml')
        collision_tree = ET.parse(collision_file)
        collision_root = collision_tree.getroot()

        statistics_tree = ET.parse(statistics_file)
        statistics_root = statistics_tree.getroot()

        rear_end_collisions = sum('se' in child.attrib.get('victim') for child in collision_root)
        total_collisions = int(statistics_root.find('safety').attrib.get('collisions'))
        try:
            emergency_brakes = int(statistics_root.find('safety').attrib.get('emergencyBraking'))
        except TypeError as e:
            emergency_brakes = 0

        for value in statistics_root.find('vehicleTripStatistics').attrib:
            if value != 'count':
                data[value] = float(statistics_root.find('vehicleTripStatistics').attrib.get(value))
            else:
                # Sumo Version 1.18.0
                data['number_of_cars'] = int(statistics_root.find('vehicleTripStatistics').attrib.get(value))

        # Sumo Version 1.12.0
        if 'number_of_cars' not in data.keys():
            vehicles = statistics_root.find('vehicles')
            data['number_of_cars'] = int(vehicles.attrib['loaded']) - int(vehicles.attrib['running'])

        data['rear_end_collisions'] = rear_end_collisions
        data['lateral_collisions'] = total_collisions - rear_end_collisions
        data['emergency_brakes'] = emergency_brakes

        experiment_data.append(data)

    df = pd.DataFrame(experiment_data)
    df.set_index('index', inplace=True)
    df.sort_index(inplace=True)

    df.to_csv(f'{experiment}/summary.csv')
