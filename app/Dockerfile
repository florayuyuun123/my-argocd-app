# Dockerfile for building the app image

# Use Node.js official image to build the app
FROM node:16

# Set the working directory inside the container
WORKDIR /app

# Copy application files to the container
COPY ./src /app

# Install dependencies
RUN npm install

# Expose the application port
EXPOSE 80

# Command to run the application
CMD ["node", "index.js"]
