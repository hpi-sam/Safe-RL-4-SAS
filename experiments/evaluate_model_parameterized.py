import json
import os
import sys
import time

from sb3_contrib import TRPO
from stable_baselines3 import A2C, DQN, PPO
from sumo_rl import SumoEnvironment

if "SUMO_HOME" in os.environ:
    tools = os.path.join(os.environ["SUMO_HOME"], "tools")
    sys.path.append(tools)
else:
    sys.exit("Please declare the environment variable 'SUMO_HOME'")
import traci


def shield(obs, action, shield_distance):
    x_position_junction = traci.junction.getPosition(traci.junction.getIDList()[0])[0]
    # action == 2 is potentially unsafe, action == 1 is always safe
    if action == 2:
        vehicles_on_main_road = traci.lane.getLastStepVehicleIDs('E0_0')
        if vehicles_on_main_road:
            position = traci.vehicle.getPosition(vehicles_on_main_road[0])[0]
            distance = abs(x_position_junction - position)
            if distance <= shield_distance:
                return 1  # safe action
    return action


def run(name, delay=0, shield_distance=0, file_name='', speed_limit=50):
    print("Running", name)
    collisions = []

    if not file_name:
        file_name = name

    additional_sumo_cmd = ['--d', str(delay)]
    additional_sumo_cmd.extend(['--duration-log.statistics'])
    additional_sumo_cmd.extend([f'--statistic-output results/{file_name}.statistics.xml'])
    additional_sumo_cmd.extend([f"--tripinfo-output results/{file_name}.tripinfo.xml"])
    additional_sumo_cmd.extend([f"--collision-output results/{file_name}.collision.xml"])
    additional_sumo_cmd.extend(["--collision.check-junctions"])

    env = SumoEnvironment(
        net_file=f"nets/simple_intersection/simple_intersection_{speed_limit}.net.xml",
        route_file="nets/simple_intersection/simple_intersection_dynamic.rou.xml",
        single_agent=True,
        use_gui=True,
        sumo_warnings=True,
        num_seconds=10000,
        additional_sumo_cmd=' '.join(additional_sumo_cmd)
    )

    model_file = f'models/{name}.zip'

    if 'a2c_collision' in name or name == 'a2c':
        model = A2C.load(model_file, env=env)
    elif name == 'dqn':
        model = DQN.load(model_file, env=env)
    elif name == 'ppo':
        model = PPO.load(model_file, env=env)
    elif name == 'trpo':
        model = TRPO.load(model_file, env=env)
    else:
        raise ValueError(f'Model "{name}" unknown')

    obs, _info = env.reset()
    traci.gui.setOffset(traci.gui.DEFAULT_VIEW, x=125, y=100)
    traci.gui.setZoom(traci.gui.DEFAULT_VIEW, 350)

    speed_limits = {id: traci.lane.getMaxSpeed(id) for id in traci.lane.getIDList()}

    done = False
    while not done:
        # print(obs)
        action, _states = model.predict(obs, deterministic=True)
        if shield_distance > 0:
            action = shield(obs, action, shield_distance)
        obs, reward, terminated, truncated, info = env.step(action)
        env.render()

        current_collisions = traci.simulation.getCollisions()
        if current_collisions:
            collisions.extend(current_collisions)

        if info['step'] == 1990:
            pass
        done = terminated or truncated

    return collisions


if __name__ == '__main__':
    model = sys.argv[1]
    filename = sys.argv[2]
    shield_distance = int(sys.argv[3])
    speed_limit = int(sys.argv[4])

    print(f"=================================================================\nEVALUATING MODEL {model} WITH SHIELD_DISTANCE {shield_distance}")
    result = run(model, shield_distance=shield_distance, file_name=filename, speed_limit=speed_limit)

    with open(f'./results/{filename}.json', 'w') as fp:
        json_content = [{
            'collider': collision.collider,
            'victim': collision.victim,
            'colliderSpeed': collision.colliderSpeed,
            'victimSpeed': collision.victimSpeed} for collision in result]
        fp.write(json.dumps(json_content, indent=4))

    print('DONE')
