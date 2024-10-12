FROM python:3.11 AS build

# Add Gem build requirements
RUN apt-get update && apt-get install -y \
  g++ \
  make \
  && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Add pip requirements
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy Site Files
COPY . .

# Run mkdocs serve
CMD ["mkdocs","serve","-a","0.0.0.0:8080"]
