# Use the latest Alpine base image and Node.js LTS
# FROM node:20-alpine AS build

# Use a valid Alpine base image
FROM alpine:3.3

# Or switch to a more recent version
# FROM alpine:3.17

# Create and set the working directory
WORKDIR /app

# Copy package files first for efficient caching
COPY package*.json /app/

# Install production dependencies
RUN npm ci --only=production

# Copy application code to the working directory
COPY ./src /app

# Expose the application port
EXPOSE 8080

# Use a non-root user for better security
RUN addgroup appgroup && adduser -S appuser -G appgroup
USER appuser

# Specify the default command to run the application
CMD ["npm", "start"]
