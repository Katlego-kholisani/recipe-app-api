FROM python:3.9-slim
LABEL maintainer="kholisani"

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Copy project files
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app

# Expose the application port
EXPOSE 8000

ARG DEV=false

# Install system dependencies and Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
        python3-dev \
        libffi-dev \
        libssl-dev \
        build-essential \
        libpq-dev \
        postgresql-client \
        libjpeg62-turbo \
        zlib1g \
        libjpeg-dev \
        zlib1g-dev \
    && python -m venv /py \
    && /py/bin/pip install --upgrade pip --timeout 100 \
    && /py/bin/pip install -r /tmp/requirements.txt --timeout 100 \
    && if [ "${DEV}" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi \
    # Remove build dependencies to keep image small (mimics apk del .tmp-build-deps)
    && apt-get purge -y --auto-remove \
        gcc \
        python3-dev \
        build-essential \
        libffi-dev \
        libssl-dev \
        libpq-dev \
        libjpeg-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Set the PATH for the virtual environment
ENV PATH="/py/bin:$PATH"

# Create a non-root user and switch to it
RUN adduser \
      --disabled-password \
      --no-create-home \
      django-user

USER django-user
