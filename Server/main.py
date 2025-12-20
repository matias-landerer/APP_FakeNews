import socket
import sys
from thread_cliente import ThreadCliente


class Servidor:
    id_clientes = 0

    def __init__(self, port: int, host: str) -> None:
        self.host = host
        self.port = port
        self.clientes = {}
        self.socket_server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    def bind_listen(self) -> None:
        self.socket_server.bind((self.host, self.port))
        self.socket_server.listen()
        print(f"Servidor escuchando en {self.host} : {self.port}")

    def accept_connections_thread(self) -> None:
        pass


if __name__ == "__main__":
    PORT = 4444 if len(sys.argv) < 2 else int(sys.argv[1])
    HOST = "localhost" if len(sys.argv) < 3 else sys.argv[2]
    server = Servidor(PORT, HOST)
    server.bind_listen()
    print("Presione Control+C para detener el servidor")
    try:
        server.accept_connections_thread()
    except KeyboardInterrupt:
        print("Cerrando servidor")

        server.socket_server.close()
        exit(1)