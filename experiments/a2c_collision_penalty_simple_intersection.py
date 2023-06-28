import glob
import os
import sys

import gymnasium as gym
import sumo_rl
from stable_baselines3 import A2C
from sumo_rl import SumoEnvironment

if "SUMO_HOME" in os.environ:
    tools = os.path.join(os.environ["SUMO_HOME"], "tools")
    sys.path.append(tools)
else:
    sys.exit("Please declare the environment variable 'SUMO_HOME'")
import traci

def collision_penalty_reward(traffic_signal: sumo_rl.TrafficSignal):
    collisions = traci.simulation.getCollisions()
    if collisions:
        return -100
    ts_wait = sum(traffic_signal.get_accumulated_waiting_time_per_lane()) / 100.0
    reward = traffic_signal.last_measure - ts_wait
    traffic_signal.last_measure = ts_wait
    return reward



def train(steps=36000):
    filelist = glob.glob(os.path.join('outputs', 'simple_intersection', "*.csv"))
    for f in filelist:
        os.remove(f)

    env = SumoEnvironment(
        net_file="nets/simple_intersection/simple_intersection.net.xml",
        route_file="nets/simple_intersection/simple_intersection.rou.xml",
        out_csv_name="outputs/simple_intersection/a2c_collision",
        reward_fn=collision_penalty_reward,
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
    model.learn(total_timesteps=steps)

    model.save('models/a2c_collision')


if __name__ == "__main__":
    train(36000)
