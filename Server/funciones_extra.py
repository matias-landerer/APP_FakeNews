from re import search

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