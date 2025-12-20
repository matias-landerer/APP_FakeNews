from socket import socket
from queue import Queue
from random import randint
from threading import Thread
import parametros as p
import json
import time


class ThreadCliente(Thread):
    def __init__(self, id_cliente: int, socket_cliente: socket, address: tuple) -> None:
        super().__init__()

        self.id_cliente = id_cliente
        self.socket = socket_cliente
        self.address = address

        self.mensajes_a_enviar = Queue()

        self.daemon = True

        self.enviar_mensajes_thread = Thread(
            target=self.procesar_mensajes_a_enviar, daemon=True
        )


    def procesar_mensajes_a_enviar(self) -> None:
        pass
    def recibir_bytes(self, cantidad: int) -> bytearray:
        pass

    def run(self) -> None:
        pass

    def procesar_mensaje(self, mensaje: dict) -> None:
        pass