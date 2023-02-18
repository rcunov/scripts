#!/bin/bash

# Simple script to send some data from Transmission to a Discord webhook when a torrent is done

# The TR_TORRENT... variables come from Transmission. Read more here:
# https://github.com/transmission/transmission/blob/main/docs/Scripts.md#on-torrent-completion

# You'll need to give this script access to your Discord webhook URL (used in this script
# as the $dcWebhookUrl var). You could store it in your .env file with this script, like 
# dcWebhookUrl=http://example.com and then pull it in with following command:
# source .env

# Or if you're running Transmission in a Docker container, you can pass it in as an
# environment variable through the Docker CLI or Docker Compose and use it that way.

# Make size of torrent human readable
torrentDescription="Size: $(numfmt --to=iec $TR_TORRENT_BYTES_DOWNLOADED)"

# Set post title
torrentTitle="Name: $TR_TORRENT_NAME"

# Read example JSON in, change values based on variables defined, and output to file 
jq --arg torrentTitle "${torrentTitle}" --arg torrentDescription "${torrentDescription}" \  # Set jq args
  '.embeds[0].title = $torrentTitle | .embeds[0].description = $torrentDescription' \  # Replace values with variables
  example.json > /tmp/dcPayload.json  # Read from example.json and store output into /tmp/dcPayload.json
                                      # because curl plays nicer with weird characters when it reads from file

# Send payload to Discord webhook
curl -H "Content-Type: application/json" -d @/tmp/dcPayload.json $dcWebhookUrl
