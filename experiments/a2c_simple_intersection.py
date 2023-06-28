import glob
import os
import sys

import gymnasium as gym
from stable_baselines3 import A2C
from sumo_rl import SumoEnvironment

if "SUMO_HOME" in os.environ:
    tools = os.path.join(os.environ["SUMO_HOME"], "tools")
    sys.path.append(tools)
else:
    sys.exit("Please declare the environment variable 'SUMO_HOME'")
import traci


def train():
    filelist = glob.glob(os.path.join('outputs', 'simple_intersection', "*.csv"))
    for f in filelist:
        os.remove(f)

    env = SumoEnvironment(
        net_file="nets/simple_intersection/simple_intersection.net.xml",
        route_file="nets/simple_intersection/simple_intersection.rou.xml",
        out_csv_name="outputs/simple_intersection/a2c",
        single_agent=True,
        use_gui=False,
        sumo_warnings=False,
        num_seconds=3600,
        additional_sumo_cmd="--collision.check-junctions"
    )

    model = A2C(
        env=env,
        policy="MlpPolicy",
        learning_rate=0.001,
        verbose=1,
    )
    model.learn(total_timesteps=36000)

    model.save('models/a2c')


def run():
    additional_sumo_cmd = ['--d', '0']
    # additional_sumo_cmd.extend(["--tripinfo-output", "data/dqn_simple_intersection/tripinfo.xml"])
    # additional_sumo_cmd.extend(["--collision-output", "data/dqn_simple_intersection/collision.xml"])
    additional_sumo_cmd.extend(["--collision.check-junctions"])

    env = SumoEnvironment(
        net_file="nets/simple_intersection/simple_intersection.net.xml",
        route_file="nets/simple_intersection/simple_intersection.rou.xml",
        out_csv_name="outputs/simple_intersection/a2c",
        single_agent=True,
        use_gui=True,
        sumo_warnings=True,
        num_seconds=3600,
        additional_sumo_cmd=' '.join(additional_sumo_cmd)
    )
    model = A2C.load('models/a2c.zip', env=env)

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


if __name__ == "__main__":
    # train()
    run()
