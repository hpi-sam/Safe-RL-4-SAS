import os
from enum import Enum


def main():
    traffic_patterns = [
        BalancedTraffic(0.1, 1000),
        BalancedTraffic(0.05, 1000),
        BalancedTraffic(0.2, 1000),
        NoTraffic(1000),
        OneLaneUnbalanced(Lanes.RIGHT_TURN, 0.1, 2, 1000),
        OneLaneUnbalanced(Lanes.VERTICAL, 0.1, 2, 1000),
        OneLaneUnbalanced(Lanes.HORIZONTAL, 0.1, 2, 1000),
        OneLaneUnbalanced(Lanes.RIGHT_TURN, 0.1, 0.5, 1000),
        OneLaneUnbalanced(Lanes.VERTICAL, 0.1, 0.5, 1000),
        OneLaneUnbalanced(Lanes.HORIZONTAL, 0.1, 0.5, 1000),
    ]

    filename = './simple_intersection/simple_intersection_dynamic.rou.xml'

    write_routefile(filename, traffic_patterns)


def write_routefile(filename, traffic_patterns):
    with open(filename, 'w') as file:
        file.write('''<?xml version="1.0" encoding="UTF-8"?>

<routes xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="http://sumo.dlr.de/xsd/routes_file.xsd">
    <vType id="vt_se" jmIgnoreFoeProb="1" jmIgnoreJunctionFoeProb="1"/>

    <route id="r_se" edges="E2 E1"/>
    <route id="r_sn" edges="E2 E3"/>
    <route id="r_we" edges="E0 E1"/>

    ''')
        file.write('\n    '.join(generate_flows(traffic_patterns)))
        file.write('\n</routes>\n')


class Lanes(Enum):
    HORIZONTAL = "r_we"
    VERTICAL = "r_sn"
    RIGHT_TURN = "r_se"


class TrafficPattern:

    def __init__(self, we_prob: float, sn_prob: float, se_prob: float, duration: int):
        self.we_prob = we_prob
        self.sn_prob = sn_prob
        self.se_prob = se_prob
        self.duration = duration


class BalancedTraffic(TrafficPattern):
    def __init__(self, probability: float, duration: int):
        super().__init__(probability, probability, probability, duration)


class OneLaneUnbalanced(TrafficPattern):
    def __init__(self, lane: Lanes, base_traffic: float, factor: float, duration):
        if lane == Lanes.HORIZONTAL:
            super().__init__(base_traffic * factor, base_traffic, base_traffic, duration)
        elif lane == Lanes.VERTICAL:
            super().__init__(base_traffic, base_traffic * factor, base_traffic, duration)
        elif lane == Lanes.RIGHT_TURN:
            super().__init__(base_traffic, base_traffic, base_traffic * factor, duration)


class NoTraffic(TrafficPattern):
    def __init__(self, duration):
        super().__init__(0.0, 0.0, 0.0, duration)


def generate_flows(traffic_patterns: list):
    current_step = 0
    flows = []
    for index, traffic_pattern in enumerate(traffic_patterns):
        end_step = current_step + traffic_pattern.duration
        if all([probability > 0 for probability in [traffic_pattern.se_prob, traffic_pattern.sn_prob, traffic_pattern.we_prob]]):
            flows.append(
                f'<flow id="we_{index}" route="r_we" begin="{current_step}" end="{end_step}" probability="{traffic_pattern.we_prob}" departPos="free"/>')
            flows.append(
                f'<flow id="sn_{index}" route="r_sn" begin="{current_step}" end="{end_step}" probability="{traffic_pattern.sn_prob}" departPos="free"/>')
            flows.append(
                f'<flow id="se_{index}" route="r_se" begin="{current_step}" end="{end_step}" probability="{traffic_pattern.se_prob}" departPos="free" type="vt_se"/>')
        current_step = end_step
    return flows


if __name__ == '__main__':
    main()
