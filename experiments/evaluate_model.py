import os
import sys
import time

from stable_baselines3 import A2C, DQN, PPO
from sumo_rl import SumoEnvironment

if "SUMO_HOME" in os.environ:
    tools = os.path.join(os.environ["SUMO_HOME"], "tools")
    sys.path.append(tools)
else:
    sys.exit("Please declare the environment variable 'SUMO_HOME'")
import traci


def shield(obs, action):
    # action == 2 is potentially unsafe, action == 1 is always safe
    if action == 2:
        vehicles_on_main_road = traci.lane.getLastStepVehicleIDs('E0_0')
        for vehicle in vehicles_on_main_road:
            position = traci.vehicle.getPosition(vehicle)
            if position[0] > 0:  # there is a car about to cross the junction
                return 1  # safe action
    return action


def run(name, delay=0, shielded=False):
    print("Running", name)
    collisions = 0

    additional_sumo_cmd = ['--d', str(delay)]
    # additional_sumo_cmd.extend(["--tripinfo-output", "data/dqn_simple_intersection/tripinfo.xml"])
    # additional_sumo_cmd.extend(["--collision-output", "data/dqn_simple_intersection/collision.xml"])
    additional_sumo_cmd.extend(["--collision.check-junctions"])

    env = SumoEnvironment(
        net_file="nets/simple_intersection/simple_intersection.net.xml",
        route_file="nets/simple_intersection/simple_intersection_dynamic.rou.xml",
        single_agent=True,
        use_gui=True,
        sumo_warnings=True,
        num_seconds=10000,
        additional_sumo_cmd=' '.join(additional_sumo_cmd)
    )

    model_file = f'models/{name}.zip'

    if name == 'a2c' or name == 'a2c_collision':
        model = A2C.load(model_file, env=env)
    elif name == 'dqn':
        model = DQN.load(model_file, env=env)
    elif name == 'ppo':
        model = PPO.load(model_file, env=env)
    else:
        raise ValueError(f'Model "{name}" unknown')

    obs, _info = env.reset()
    traci.gui.setOffset(traci.gui.DEFAULT_VIEW, x=125, y=100)
    traci.gui.setZoom(traci.gui.DEFAULT_VIEW, 350)

    overwrite_action = False

    done = False
    while not done:
        # print(obs)
        action, _states = model.predict(obs, deterministic=True)
        if shielded:
            action = shield(obs, action)
        obs, reward, terminated, truncated, info = env.step(action)
        env.render()

        current_collisions = traci.simulation.getCollisions()
        if current_collisions:
            print(current_collisions)
            collisions += len(current_collisions)

        if info['step'] == 1990:
            pass
        done = terminated or truncated

    return {'Collisions': collisions}


if __name__ == '__main__':
    models = ['a2c', 'dqn', 'ppo', 'a2c_collision', 'a2c_shielded']
    results = {}
    for model in models:
        if "shielded" not in model:
            results[model] = run(model)
        else:
            results[model] = run(model, shielded=True)
        time.sleep(3)
    print(results)

