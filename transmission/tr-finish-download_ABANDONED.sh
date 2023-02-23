#!/bin/bash

# Simple script to send some data from Transmission to a Discord webhook when a torrent is done

# The TR_TORRENT... variables come from Transmission. Read more here:
# https://github.com/transmission/transmission/blob/main/docs/Scripts.md#on-torrent-completion

# You'll need to give this script access to your Discord webhook URL (used in this script
# as the $dcWebhookUrl var). You could store it in your .env file with this script, like 
# dcWebhookUrl=http://example.com and then pull it in with following command:
#source .env

# Or if you're running Transmission in a Docker container, you can pass it in as an
# environment variable through the Docker CLI or Docker Compose and use it that way.

# Establish location of script so it can be called from anywhere using relative paths
scriptLoc=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
echo "scriptLoc: $scriptLoc"

# Make size of torrent human readable
torrentDescription="Size: $(numfmt --to=iec $TR_TORRENT_BYTES_DOWNLOADED)"
echo "torrentDescription= $torrentDescription"

# Set post title
torrentTitle="Name: $TR_TORRENT_NAME"
echo "torrentTitle= $torrentTitle"

# Read example JSON in, change values based on variables defined, and output to file 
jq --arg torrentTitle "${torrentTitle}" --arg torrentDescription "${torrentDescription}" \
  '.embeds[0].title = $torrentTitle | .embeds[0].description = $torrentDescription' \
   $scriptLoc/example.json > $scriptLoc/dcPayload.json
# Reading from a file negates the need to use escape characters, which makes things 100x easier

# Read JSON data from file and send to Discord webhook
curl -H "Content-Type: application/json" -d @$scriptLoc/dcPayload.json $dcWebhookUrl

# Get rid of old webhook data
rm -f $scriptLoc/dcPayload.json
