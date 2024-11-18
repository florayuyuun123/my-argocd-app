# Use the official Node.js LTS Alpine image as the base image
FROM node:18-alpine AS build

# Create and set the working directory
WORKDIR /app

# Copy package files first for efficient caching
COPY package*.json /app/

# Install dependencies (production dependencies only)
RUN npm ci --only=production

# Copy application code to the working directory
COPY ./src /app

# Expose the application port
EXPOSE 3000

# Use a non-root user for better security
RUN addgroup appgroup && adduser -S appuser -G appgroup
USER appuser

# Specify the default command to run the application
CMD ["npm", "start"]
