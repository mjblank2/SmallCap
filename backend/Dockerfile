FROM python:3.10-slim
WORKDIR /app

# Optimize Python execution
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

COPY requirements.txt /app/

# Install system dependencies required for compiling libraries (TA-Lib and psycopg2)
RUN apt-get update && apt-get install -y build-essential wget gcc libpq-dev

# Install TA-Lib (Required for advanced technical analysis)
RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz && \
    tar -xzf ta-lib-0.4.0-src.tar.gz && \
    cd ta-lib/ && \
    ./configure --prefix=/usr && \
    make && make install && \
    cd .. && rm -rf ta-lib ta-lib-0.4.0-src.tar.gz

# Install Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Clean up build dependencies
RUN apt-get remove -y build-essential wget gcc && apt-get autoremove -y && apt-get clean

# Install NLTK data required for VADER sentiment analysis
RUN python -m nltk.downloader vader_lexicon

# Copy application code and the entrypoint script
COPY . /app

# Ensure the entrypoint script is executable
RUN chmod +x /app/entrypoint.sh

EXPOSE 8000

# Set the command to execute the entrypoint script
CMD ["/app/entrypoint.sh"]
