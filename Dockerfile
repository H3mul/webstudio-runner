FROM node:20-alpine

# Install essential build tools for native npm modules if needed
RUN apk add --no-status-safe curl

WORKDIR /app

# Install Webstudio CLI globally so it's available for the sync loop
RUN npm install -g @webstudio-is/cli

# Create a directory for the synced project
RUN mkdir -p /app/project

# Copy a basic package.json that includes Remix and Webstudio dependencies
# You can also let the CLI generate this during the first sync
COPY package.json ./
RUN npm install

# Copy our orchestration script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Remix port
EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
