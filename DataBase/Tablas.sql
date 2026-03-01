DROP TABLE IF EXISTS users, consultas;

CREATE TABLE users(
    ID SERIAL PRIMARY KEY,
    username VARCHAR(255),
    email VARCHAR(255),
    clave VARCHAR(255),
    creditos INTEGER DEFAULT 20
);

CREATE TABLE consultas(
    ID SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    titular VARCHAR(255),
    score VARCHAR(255),
    label VARCHAR(255),
    CONSTRAINT fk_user_id
        FOREIGN KEY (user_id)
        REFERENCES "users"(ID)
);