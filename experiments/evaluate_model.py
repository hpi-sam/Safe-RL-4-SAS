import os
import sys

from stable_baselines3 import A2C, DQN, PPO
from sumo_rl import SumoEnvironment

if "SUMO_HOME" in os.environ:
    tools = os.path.join(os.environ["SUMO_HOME"], "tools")
    sys.path.append(tools)
else:
    sys.exit("Please declare the environment variable 'SUMO_HOME'")
import traci


def run(name, delay=0):
    additional_sumo_cmd = ['--d', str(delay)]
    # additional_sumo_cmd.extend(["--tripinfo-output", "data/dqn_simple_intersection/tripinfo.xml"])
    # additional_sumo_cmd.extend(["--collision-output", "data/dqn_simple_intersection/collision.xml"])
    additional_sumo_cmd.extend(["--collision.check-junctions"])

    env = SumoEnvironment(
        net_file="nets/simple_intersection/simple_intersection.net.xml",
        route_file="nets/simple_intersection/simple_intersection.rou.xml",
        single_agent=True,
        use_gui=True,
        sumo_warnings=True,
        num_seconds=3600,
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

    done = False
    while not done:
        action, _states = model.predict(obs, deterministic=True)
        obs, reward, terminated, truncated, info = env.step(action)
        env.render()

        current_collisions = traci.simulation.getCollisions()
        if current_collisions:
            print(current_collisions)

        if info['step'] == 500:
            print(info)
            pass
        done = terminated or truncated


if __name__ == '__main__':
    # run('a2c', 50)
    # run('dqn', 50)
    # run('ppo', 50)
    run('a2c_collision', 50)
