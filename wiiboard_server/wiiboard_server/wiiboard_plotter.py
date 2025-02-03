import socket
import struct
import matplotlib.pyplot as plt
import math
import time

DATABUFFER_LIMIT = 50

class WiiPlotter:
    def __init__(self):
        self.fig = plt.figure()
        self.ax = self.fig.add_subplot(1,1,1)
        self.databuffer = []
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.running = True

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

            self.sock.setblocking(False)
            try:
                _trash = self.sock.recv(1024)
            except BlockingIOError:
                pass
            self.sock.setblocking(True)

            data = str(data, "utf-8")

            corners = [float(i) for i in data.split(";")]
            self.databuffer.append(corners)
            if len(self.databuffer) > DATABUFFER_LIMIT:
                self.databuffer.pop(0)
            
            self.ax.clear()
            for i in range(4):
                self.ax.plot(range(len(self.databuffer)), [d[i] for d in self.databuffer])
            
            self.ax.plot(range(len(self.databuffer)), [sum(d) for d in self.databuffer])

            plt.pause(0.01)

def main():
    plotter = WiiPlotter()
    plotter.run("localhost", 42069)

if __name__ == "__main__":
    main()