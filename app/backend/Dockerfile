FROM python:latest

WORKDIR /api

COPY . .

RUN pip install --no-cache-dir --upgrade -r requirements.txt

EXPOSE 5006

ENV PYTHONUNBUFFERED=1

CMD ["gunicorn", "-k", "eventlet", "-w", "1", "-b", "0.0.0.0:5006", "--access-logfile", "-", "--error-logfile", "-", "--log-level", "info", "main:app"]
