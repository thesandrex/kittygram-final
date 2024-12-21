FROM python:3.10 AS build
WORKDIR /code
COPY requirements.txt .
RUN python -m venv /venv
RUN /venv/bin/pip install -r requirements.txt
COPY . .

FROM python:3.10-alpine
ENV PYTHONUNBUFFERED=1
COPY --from=build /code /code
ENV PATH="/venv/bin:$PATH"
EXPOSE 8000
# CMD ["/bin/sh", "-c", ". venv/bin/activate && python code/manage.py runserver 0.0.0.0:8000"]
CMD ["python","code/manage.py","runserver","0.0.0.0:8000"]
