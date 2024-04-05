# Safe Reinforcement Learning for Self-Adaptive Systems
Project Seminar on Safe Reinforcement Learning for Self-Adaptive Systems

**ABSTRACT**

One significant challenge in traffic control systems is managing
unprotected right turns at intersections, where the absence of dedicated
turning signals can create collision risks. In this report we
explore how to utilize reinforcement learning algorithms to dynamically
adjust traffic light phases for mitigating collision risks
while optimizing traffic flow. We use Simulation of Urban Mobility
(SUMO) to simulate intersection traffic, integrating RL algorithms
such as Deep Q-Learning (DQN), Advantage Actor Critic (A2C),
Proximal Policy Optimization (PPO), and Trust Region Policy Optimization
(TRPO) through SUMO-RL. In the report we investigate
the impact of RL algorithms and speed limits on safety and efficiency,
evaluating performance based on collision occurrences and
time loss metrics. Results showTRPO’s superior safety performance,
while A2C exhibits the smallest time loss. Further analysis shows
the influence of speed limits on collision types. Additionally, we
introduce a shield algorithm to enhance safety in A2C agents, observing
a trade-off between safety improvement and performance
degradation. The report concludes with avenues for future research,
including optimizing shield distances and incorporating safety into
RL rewards.
