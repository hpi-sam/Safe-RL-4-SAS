import os
import sys

import gymnasium as gym
from stable_baselines3 import DQN
from sumo_rl import SumoEnvironment

if "SUMO_HOME" in os.environ:
    tools = os.path.join(os.environ["SUMO_HOME"], "tools")
    sys.path.append(tools)
else:
    sys.exit("Please declare the environment variable 'SUMO_HOME'")
import traci


def main_gym():
    env = gym.make('sumo-rl-v0',
                   net_file="nets/simple_intersection/simple_intersection.net.xml",
                   route_file="nets/simple_intersection/simple_intersection.rou.xml",
                   out_csv_name="outputs/simple_intersection/dqn",
                   use_gui=True,
                   num_seconds=3600)

    obs, info = env.reset()
    done = False
    while not done:
        next_obs, reward, terminated, truncated, info = env.step(env.action_space.sample())
        done = terminated or truncated

    pass


def train():
    env = SumoEnvironment(
        net_file="nets/simple_intersection/simple_intersection.net.xml",
        route_file="nets/simple_intersection/simple_intersection.rou.xml",
        out_csv_name="outputs/simple_intersection/dqn",
        single_agent=True,
        use_gui=False,
        sumo_warnings=False,
        num_seconds=3600,
        additional_sumo_cmd="--collision.check-junctions"
    )

    model = DQN(
        env=env,
        policy="MlpPolicy",
        learning_rate=0.001,
        learning_starts=0,
        train_freq=1,
        target_update_interval=500,
        exploration_initial_eps=0.05,
        exploration_final_eps=0.01,
        verbose=1,
    )
    model.learn(total_timesteps=36000)

    model.save('models/dqn')


def run():
    env = SumoEnvironment(
        net_file="nets/simple_intersection/simple_intersection.net.xml",
        route_file="nets/simple_intersection/simple_intersection.rou.xml",
        out_csv_name="outputs/simple_intersection/dqn",
        single_agent=True,
        use_gui=True,
        num_seconds=3600,
        # additional_sumo_cmd=f"--delay 100 --collision.check-junctions"
    )
    model = DQN.load('models/dqn.zip')

    obs, state = env.reset()
    traci.gui.setOffset(traci.gui.DEFAULT_VIEW, x=125, y=100)
    traci.gui.setZoom(traci.gui.DEFAULT_VIEW, 350)

    done = False
    while not done:
        action, _states = model.predict(obs, state)
        next_obs, reward, terminated, truncated, state = env.step(action)
        done = terminated or truncated


if __name__ == "__main__":
    train()
    # run()
