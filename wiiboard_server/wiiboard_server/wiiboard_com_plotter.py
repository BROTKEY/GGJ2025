import numpy as np
import matplotlib.pyplot as plt
import time
import socket

TRAIL_LENGTH = 50
PLOT_UPDATE_INTERVAL = 10/1000
PLOT_LIMIT = 100

class WiiPlot():
    def __init__(self):
        fig, ax = plt.subplots()
        ax.set_xlim(-PLOT_LIMIT, PLOT_LIMIT)
        ax.set_ylim(-PLOT_LIMIT, PLOT_LIMIT)
        ax.axhline()
        ax.axvline()
        self.point, = ax.plot([], [], 'bo', markersize=8)
        self.trail, = ax.plot([], [], 'r-', markersize=5)
        self.x_data = []
        self.y_data = []
        self.next_plot_update = time.time() + PLOT_UPDATE_INTERVAL
        self.databuffer = []
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.running = True
        plt.ion()
    
    def run(self, addr, port):
        self.sock.connect((addr, port))

        while self.running:
            data = self.sock.recv(4)
            if not data:
                self.running = False
                break
            
            data = self.sock.recv(data[0])
            if not data:
                self.running = False
                break

            data = str(data, "utf-8")

            corners = [float(i) for i in data.split(";")]
            self.on_mass(corners)

    def on_mass(self, corners):
        x = corners[0] + corners[1] - corners[2] - corners[3]
        y = corners[0] + corners[2] - corners[1] - corners[3]
        self.x_data.append(x)
        self.y_data.append(y)

        if len(self.x_data) > TRAIL_LENGTH:
            self.x_data.pop(0)
            self.y_data.pop(0)

        self.point.set_data([self.x_data[-1]], [self.y_data[-1]])
        self.trail.set_data(self.x_data, self.y_data)

        t = time.time()
        if time.time() > self.next_plot_update:
            plt.draw()
            plt.pause(0.00001)
            self.next_plot_update = time.time() + PLOT_UPDATE_INTERVAL

def main():
    wiiplot = WiiPlot()
    wiiplot.run("localhost", 42069)

if __name__ == "__main__":
    main()