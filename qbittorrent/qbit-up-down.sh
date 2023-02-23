#!/bin/bash

# Simple script to send some data from qBittorrent to a Discord webhook when a torrent is added or done

# You'll need to give this script access to your Discord webhook URL (used in this script
# as the $dcWebhookUrl var). You could store it in your .env file with this script, like 
# dcWebhookUrl=http://example.com and then pull it in with following command:
#source .env

# Or if you're running qBittorrent in a Docker container, you can pass it in as an
# environment variable through the Docker CLI or Docker Compose and use it that way.

# Run in background. Not sure if necessary
set -m

# Set post title and color depending on if script is run when torrent is added or finished
case $1 in
  added) postTitle="Torrent added:" && color=16103168;;
  finished) postTitle="Torrent downloaded:" && color=3715072;;
  *) echo "First argument must be either \"added\" or \"finished\"" 1>&2; exit 1;;
esac

# Move to a folder where we have permissions
cd /tmp

# Make size of torrent human readable
torrentDescription="Size: $(numfmt --to=iec $2)"  # Use the %Z and %N variables from qBittorrent

# Set embed title
torrentTitle="Name: $3"

# Read example JSON in, change values based on variables defined, and output to file 
jq --arg torrentTitle "${torrentTitle}" --arg torrentDescription "${torrentDescription}" \
  --arg postTitle "${postTitle}" --arg color "${color}" \
  '.embeds[0].title=$torrentTitle | .embeds[0].description=$torrentDescription |
  .embeds[0].color=$color | .content=$postTitle' \
  example.json > dcPayload.json
# Reading from a file negates the need to use escape characters, which makes things 100x easier

# Read JSON data from file and send to Discord webhook
curl -H "Content-Type: application/json" -d @dcPayload.json $dcWebhookUrl

# Get rid of old webhook data
rm -f dcPayload.json
