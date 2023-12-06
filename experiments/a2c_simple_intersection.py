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


def train(steps=100000, speed_limit=50):

    env = SumoEnvironment(
        net_file=f"nets/simple_intersection/simple_intersection_{speed_limit}.net.xml",
        route_file="nets/simple_intersection/simple_intersection_dynamic.rou.xml",
        out_csv_name=f"outputs/simple_intersection/a2c_{speed_limit}",
        single_agent=True,
        use_gui=False,
        sumo_warnings=False,
        num_seconds=10000,
        additional_sumo_cmd="--collision.check-junctions"
    )

    model = A2C(
        env=env,
        policy="MlpPolicy",
        learning_rate=0.001,
        verbose=1,
    )
    model.learn(total_timesteps=steps)

    model.save(f'models/a2c_{speed_limit}_100000')


if __name__ == "__main__":
    speed = sys.argv[1]
    train(100000, int(speed))
