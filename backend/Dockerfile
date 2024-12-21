FROM python:3.10
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt --no-cache-dir
COPY . .
ENV PYTHONUNBUFFERED=1
RUN chmod +x *.sh
CMD ["/bin/sh", "-c", "/app/entrypoint.sh"]
