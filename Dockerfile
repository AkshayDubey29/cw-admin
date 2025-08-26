# Use the official Node.js runtime as the base image
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including dev dependencies) with retry logic
RUN npm config set fetch-retry-mintimeout 20000 && \
    npm config set fetch-retry-maxtimeout 120000 && \
    npm config set fetch-retries 5 && \
    npm ci --prefer-offline

# Copy the rest of the application
COPY . .

# Build the application (all dependencies already installed)
RUN npm run build

# Remove dev dependencies to reduce image size
RUN npm prune --production

# Expose the port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
