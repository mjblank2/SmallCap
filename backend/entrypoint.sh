#!/bin/bash
# Stop the script if any command fails
set -e

# Check the SERVICE_ROLE environment variable set by Render
case "$SERVICE_ROLE" in
  "WEB")
    echo "Starting Web API (Gunicorn)..."
    # Render provides $PORT automatically for web services.
    # 'exec' ensures the command replaces the script process, allowing signals to be handled correctly.
    exec gunicorn --bind 0.0.0.0:$PORT app:app
    ;;
  "WORKER")
    echo "Starting Celery Worker..."
    # Assumes Celery app is defined in tasks.py as celery_app
    exec celery -A tasks:celery_app worker --loglevel=INFO
    ;;
  "SCHEDULER")
    echo "Starting Celery Beat Scheduler..."
    exec celery -A tasks:celery_app beat --loglevel=INFO
    ;;
  *)
    # Handle cases where SERVICE_ROLE is missing or incorrect
    echo "Error: Unknown or missing SERVICE_ROLE '$SERVICE_ROLE'. Defaulting to WEB."
    exec gunicorn --bind 0.0.0.0:$PORT app:app
    ;;
esac
