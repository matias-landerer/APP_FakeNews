FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

ENV GUNICORN_CMD_ARGS="--workers 2 --threads 4 --worker-class gthread --timeout 90 --access-logfile - --error-logfile -"
CMD ["gunicorn", "-b", "0.0.0.0:5000", "main:app"]