from socket import socket
from random import shuffle
from threading import Thread
from API import verificar_titular
import parametros
import json
import psycopg

class ThreadCliente(Thread):
    def __init__(self, id_cliente: int, socket_cliente: socket, address: tuple) -> None:
        super().__init__()

        self.id_cliente = id_cliente
        self.socket = socket_cliente
        self.address = address

        self.daemon = True

        self.conectado = True

    def registrarse(self, username: str, email: str, password: str) -> None:
        conn = psycopg.connect(
            host=parametros.host,
            dbname=parametros.dbname,
            user=parametros.user,
            password=parametros.password
        )
        
        with conn.cursor() as cur:
            cur.execute(
            "INSERT INTO users (ID, username, email, clave) VALUES (%s, %s, %s, %s)",
            (self.id_cliente, username, email, password)
        )
        conn.commit()
        conn.close()
    
    def iniciar_sesion(self, username: str, password: str) -> None:
        conn = psycopg.connect(
            host=parametros.host,
            dbname=parametros.dbname,
            user=parametros.user,
            password=parametros.password
        )
        
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM users WHERE username = %s;", (username,))
            filas = cur.fetchall()
            if filas[0][3] != password:
                print("ERROR")
                self.desconectado()
            self.id_cliente = filas[0][0]
        
        conn.close()
    
    def desconectado(self) -> None:
        self.conectado = False
        print(f'Cliente N° {self.id_cliente} se ha desconectado')
        self.socket.close()
    
    def ingresar_titular(self, titular) -> None:
        resultado = verificar_titular(titular)

        mensaje = {'Resultado' : resultado}

        self.enviar_mensaje(mensaje)

    def enviar_mensaje(self, mensaje: dict) -> None:
        mensaje_bytes = json.dumps(mensaje).encode('utf-8')
        mensaje_len = len(mensaje_bytes)
        if mensaje_len % parametros.N_BYTES_CHUNCK != 0:
            relleno = parametros.N_BYTES_CHUNCK - (mensaje_len % parametros.N_BYTES_CHUNCK)
            mensaje_bytes += b'\x00' * relleno
        
        total_paquetes = []
        for i in range(0, len(mensaje_bytes), parametros.N_BYTES_CHUNCK):
            chunck = mensaje_bytes[i:i + parametros.N_BYTES_CHUNCK]
            id_chunck = (i // parametros.N_BYTES_CHUNCK).to_bytes(parametros.N_BYTES_ID, byteorder = 'big')
            paquete_actual = id_chunck + chunck
            paquete_actual_xor = bytes(x ^ y for x, y in zip(paquete_actual, parametros.CLAVE_CIFRADO))
            total_paquetes.append(paquete_actual_xor)
        
        shuffle(total_paquetes)
        largo_contenido = mensaje_len.to_bytes(parametros.N_BYTES_LEN, byteorder = "little")

        paquete_final = largo_contenido + b''.join(total_paquetes)
        self.socket.sendall(paquete_final)
    
    def recibir_mensaje(self) -> None:
        try:
            while self.conectado:
                mensaje = self.socket.recv(4096)
                if not mensaje:
                    self.desconectado()
                else:
                    accion = self.procesar_mensaje_recibido(mensaje)
                    if 'Registrarse' in accion:
                        self.registrarse()
                    elif 'IniciarSesion' in accion:
                        self.iniciar_sesion(accion['IniciarSesion'][0], accion['IniciarSesion'][1])
                    elif 'Titular' in accion:
                        self.ingresar_titular(accion['Titular'])
        except ConnectionResetError:
            self.desconectado()

    def procesar_mensaje_recibido(self, mensaje: bytes) -> dict:
        largo_original = int.from_bytes(mensaje[:parametros.N_BYTES_LEN], "little")
        paquetes = [mensaje[i:i + parametros.N_BYTES_CHUNCK + parametros.N_BYTES_ID]
                    for i in range(parametros.N_BYTES_LEN, len(mensaje), parametros.N_BYTES_CHUNCK +
                                   parametros.N_BYTES_ID)]
        chunks = dict()
        for paquete_cifrado in paquetes:
            paquete = bytes(x ^ y for x, y in zip(paquete_cifrado, parametros.CLAVE_CIFRADO))
            id_chunk = int.from_bytes(paquete[:parametros.N_BYTES_ID], "big")
            chunks[id_chunk] = paquete[parametros.N_BYTES_ID:]

        mensaje_reconstruido = b''.join(chunks[i] for i in sorted(chunks))
        mensaje_reconstruido_final = mensaje_reconstruido[:largo_original]
        return json.loads(mensaje_reconstruido_final.decode("utf-8"))

    def run(self) -> None:
        self.recibir_mensaje()
