# Use official Node.js image
FROM node:18

# Set working directory
WORKDIR /app

# Install Medusa CLI and dependencies
RUN npm install -g @medusajs/medusa-cli@latest

# Copy package files and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the entire project
COPY . .

# Expose Medusa's default port
EXPOSE 9000

# Start Medusa backend
CMD ["medusa", "develop"]
