FROM node:20-alpine

# Install essential build tools
RUN apk add curl

WORKDIR /app

# Pin the Webstudio CLI version
# renovate: datasource=npm depName=@webstudio-is/cli
ENV WEBSTUDIO_CLI_VERSION=0.94.0
RUN npm install -g @webstudio-is/cli@${WEBSTUDIO_CLI_VERSION}

# Create a directory for the synced project
RUN mkdir -p /app

# Copy a basic package.json that includes Remix and Webstudio dependencies
COPY package.json ./
RUN npm install

# Copy our orchestration script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Remix port
EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
