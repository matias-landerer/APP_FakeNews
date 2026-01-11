CREATE TABLE users(
    ID INTEGER PRIMARY KEY,
    username VARCHAR(255),
    email VARCHAR(255),
    clave VARCHAR(255),
    is_premium BOOLEAN DEFAULT false
);

CREATE TABLE Consultas(
    ID SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    titular VARCHAR(255),
    resultado VARCHAR(255),
    fecha TIMESTAMP
    CONSTRAINT fk_user_id
        FOREIGN KEY (user_id)
        REFERENCES "users"(ID)
);