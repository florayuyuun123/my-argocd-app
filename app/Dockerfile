# Use the official Node.js image as the base image
FROM node:16

# Set the working directory
WORKDIR /app

# Copy the package.json and package-lock.json to the working directory
COPY package*.json /app/

# Install dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY ./src /app

# Expose the application port
EXPOSE 3000

# Specify the default command to run the application
CMD ["npm", "start"]
