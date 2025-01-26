from wiiboard_server.wiiboard.wiiboard import Wiiboard, discover
from threading import Thread
import socket, time

TRANSMIT_RATE_S = 0.02

class BoardSocket(Wiiboard):
    def __init__(self, address=None):
        self.board_thread = None
        self.corners = {
            "top_right":    0.0,
            "bottom_right": 0.0,
            "top_left":     0.0,
            "bottom_left":  0.0
        }
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.bind(("0.0.0.0", 42069))
        self.sock.listen(8)
        self.running = True
        super().__init__(address)

    def run(self):
        self.board_thread = Thread(target=self.loop)
        self.board_thread.start()
        
        while self.running:
            conn, addr = self.sock.accept()
            print(f"{addr} connected!")
            
            conn_thread = Thread(target=self.conn_loop, args=[conn, addr])
            conn_thread.start()

    def conn_loop(self, conn, addr):
        next_update = time.time()
        while self.running:
            if not conn:
                break

            if time.time() > next_update:
                data = ";".join(str(i) for i in self.corners.values())
                data = chr(len(data)) + "\0\0\0" + data
                try: 
                    conn.send(bytes(data, "utf-8"))
                except:
                    print("Broken Pipe")
                    break
                next_update = time.time() + TRANSMIT_RATE_S
            
        print(f"{addr} disconnected!")

    def on_mass(self, mass):
        self.corners = mass

    def __del__(self):
        self.running = False
        self.sock.close()
        return super().__del__()

def main():
    wii_boards = discover(6)
    if not wii_boards:
        raise Exception("No Wii Fit Balanceboards found!")
    
    server = BoardSocket(wii_boards[0])
    server.run()

if __name__ == "__main__":
    main()