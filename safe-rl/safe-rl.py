import os
import sys


class Simulation:

    def __init__(self, nogui=False):

        if 'SUMO_HOME' in os.environ:
            tools = os.path.join(os.environ['SUMO_HOME'], 'tools')
            sys.path.append(tools)
        else:
            sys.exit("please declare environment variable 'SUMO_HOME'")

        from sumolib import checkBinary  # noqa

        if nogui:
            self.sumoBinary = checkBinary('sumo')
        else:
            self.sumoBinary = checkBinary('sumo-gui')

    def run(self):
        import traci  # noqa

        sumoCmd = [self.sumoBinary]
        sumoCmd.extend(["-c", "../nets/simple_intersection/simple_intersection.sumocfg"])
        sumoCmd.extend(["--tripinfo-output", "../data/tripinfo.xml"])
        sumoCmd.extend(["--collision-output", "../data/collision.xml"])
        sumoCmd.extend(["--collision.check-junctions"])
        # sumoCmd.extend(["--collision.action", "warn"])
        # sumoCmd.extend(["--collision.mingap-factor", "0"])

        traci.start(sumoCmd)
        traci.gui.setOffset(traci.gui.DEFAULT_VIEW, x=125, y=100)
        traci.gui.setZoom(traci.gui.DEFAULT_VIEW, 350)

        step = 0
        duration = 10000

        while step < duration:
            traci.simulationStep()
            step += 1
            print('step:', step)

        traci.close()


def main():
    simulation = Simulation()

    simulation.run()

    sys.exit()


if __name__ == '__main__':
    main()
