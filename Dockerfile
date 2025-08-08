# Use official Racket base image
FROM racket/racket:8.17-full as build

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl gnupg git postgresql-client && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Set working directory
WORKDIR /goodtool

# Copy application code
COPY . .

# Install Node dependencies and build frontend
RUN npm install && npm run build

# Install Racket dependencies
RUN raco pkg install --auto chief && \
   raco pkg install --auto ./tooldb

# Optional: copy .env.default to .env if .env doesn't exist
#RUN [ -f .env ] || cp .env.default .env

# Set environment variable to disable SSL requirement
#ENV TOOLDB_DEBUG=x

# Expose port (assume 8000)
EXPOSE 5100

# Default command to run the application
CMD ["raco", "chief", "start"]

#CMD bash