#!/bin/sh

# Ensure required variables are set
if [ -z "$WEBSTUDIO_PROJECT_ID" ] || [ -z "$BUILDER_URL" ]; then
  echo "ERROR: WEBSTUDIO_PROJECT_ID and BUILDER_URL must be set."
  exit 1
fi

echo "Connecting to Webstudio Builder at $BUILDER_URL..."

# 1. Link the project (Project-Agnostic step)
webstudio link --host "$BUILDER_URL" --project "$WEBSTUDIO_PROJECT_ID"

# 2. Initial Sync
echo "Performing initial sync..."
webstudio sync

# 3. Initial Build
echo "Performing initial build..."
npm run build

# 4. The Infinite Sync Loop (Run in background)
# This keeps the container updated and sends its logs to stdout.
SYNC_INTERVAL=${SYNC_INTERVAL:-300} # Default to 5 minutes

(
  echo "Starting background sync loop (Interval: ${SYNC_INTERVAL}s)..."
  while true; do
    sleep "$SYNC_INTERVAL"
    echo "Checking for design updates..."
    webstudio sync
    # If the sync changes files, we rebuild. 
    # npm run start (Remix) should pick up the changes if it supports hot reloading.
    npm run build
  done
) &

# 5. Start the server in the foreground
# Running this with exec ensures it remains the main process and logs directly to stdout.
# Since the sync loop is in the background, both will share stdout.
echo "Starting the application server..."
exec npm run start