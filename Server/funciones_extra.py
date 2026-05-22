import jwt
import parametros
from re import search
from flask import request

def password_error(password: str) -> str | None:
    if len(password) < 8:
        return "Mínimo 8 caracteres"
    if not search(r'[a-z]', password):
        return "Debe incluir una minúscula"
    if not search(r'[A-Z]', password):
        return "Debe incluir una mayúscula"
    if not search(r'\d', password):
        return "Debe incluir un número"
    if not search(r'[!@#$%^&*(),.?":{}|<>_-]', password):
        return "Debe incluir un símbolo"
    return None

def isvalidEmail (email: str) -> bool:
    return search(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', email)

def get_current_user():
    auth = request.headers.get("Authorization", "")
    if not auth.startswith("Bearer "):
        return None
    token = auth.split(" ", 1)[1]
    try:
        payload = jwt.decode(token, parametros.JWT_SECRET, algorithms=["HS256"])
        return payload["user_id"]
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None
    
def check_rate_limit(r, key: str, limit: int, window: int) -> tuple[bool, int]:
    """
    Retorna (bloqueado, segundos_restantes).
    Usa sliding window con INCR + EXPIRE en Redis.
    """
    current = r.incr(key)
    if current == 1:
        r.expire(key, window)
    if current > limit:
        ttl = r.ttl(key)
        r.decr(key)
        return True, ttl
    return False, 0
