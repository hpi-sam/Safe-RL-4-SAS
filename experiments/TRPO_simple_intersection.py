import glob
import os
import sys

import gymnasium as gym
from sb3_contrib import TRPO
from sumo_rl import SumoEnvironment

if "SUMO_HOME" in os.environ:
    tools = os.path.join(os.environ["SUMO_HOME"], "tools")
    sys.path.append(tools)
else:
    sys.exit("Please declare the environment variable 'SUMO_HOME'")
import traci


def train(steps):
    filelist = glob.glob(os.path.join('outputs', 'simple_intersection', "*.csv"))
    for f in filelist:
        os.remove(f)

    env = SumoEnvironment(
        net_file="nets/simple_intersection/simple_intersection.net.xml",
        route_file="nets/simple_intersection/simple_intersection_dynamic.rou.xml",
        out_csv_name="outputs/simple_intersection/dqn",
        single_agent=True,
        use_gui=False,
        sumo_warnings=False,
        num_seconds=10000,
        additional_sumo_cmd="--collision.check-junctions"
    )

    model = TRPO(
        env=env,
        policy="MlpPolicy",
        learning_rate=0.001,
        verbose=1,
    )
    model.learn(total_timesteps=steps)

    model.save('models/trpo')


if __name__ == "__main__":
    train(100000)
