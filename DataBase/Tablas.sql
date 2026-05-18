CREATE EXTENSION IF NOT EXISTS "pgcrypto";
DROP TABLE IF EXISTS users, consultas;

CREATE TABLE users(
    ID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(255),
    email VARCHAR(255),
    clave VARCHAR(255),
    creditos INTEGER DEFAULT 20,
    verified BOOLEAN DEFAULT FALSE,
    verify_token VARCHAR(64),
    revoke_token VARCHAR(64),
    session_revoked BOOLEAN DEFAULT FALSE,
    reset_token VARCHAR(64),
    reset_token_expiry TIMESTAMP
);

CREATE TABLE consultas(
    ID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    titular VARCHAR(255),
    score VARCHAR(255),
    label VARCHAR(255),
    CONSTRAINT fk_user_id
        FOREIGN KEY (user_id)
        REFERENCES "users"(ID)
);