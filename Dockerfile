FROM python:3.10-slim

WORKDIR /app

ENV VIRTUAL_ENV=/venv
RUN python -m venv --copies $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# ----> Consider no dev deps and --no-ansi. --no-interaction?
RUN pipx install poetry

# Install dependencies before ISAR to cache poetry installation
RUN mkdir -p src
COPY pyproject.toml poetry.lcok README.md ./
RUN poetry install --no-ansi --no-interaction --only main

# Install the base isar-robot package
RUN pip install isar-robot

COPY . .

# Do we need to add anything here for poetry? for instance COPY pyproject.toml and poetry.lock?
RUN poetry install

EXPOSE 3000

# Env variable for ISAR to know it is running in docker
ENV IS_DOCKER=true

# # Add non-root user
RUN useradd --create-home --shell /bin/bash 1000
RUN chown -R 1000 /app
RUN chmod 755 /app
USER 1000

CMD python main.py
