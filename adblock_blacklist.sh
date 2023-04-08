#!/bin/bash

ROUTER_IP="192.168.1.1"
ROUTER_USERNAME="admin"
ROUTER_PASSWORD="password"
BLACKLISTED_DOMAINS=("ads.example.com" "trackers.example.com" "analytics.example.com")

# Log in to the router and get the token
TOKEN=$(curl -s -c /tmp/cookies.txt "http://$ROUTER_USERNAME:$ROUTER_PASSWORD@$ROUTER_IP/login.asp" | grep "token" | awk -F "=" '{print $2}' | awk -F "\"" '{print $2}')

# Get the current Adblock settings
CURRENT_SETTINGS=$(curl -s -b /tmp/cookies.txt -c /tmp/cookies.txt "http://$ROUTER_IP/update.cgi?target=adblock" | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')

# Add the blacklisted domains to the settings
for DOMAIN in "${BLACKLISTED_DOMAINS[@]}"; do
  NEW_SETTING=$(echo "$CURRENT_SETTINGS" | sed "s/\"adblock_blacklist\"\:\[/\"adblock_blacklist\"\:\[\"$DOMAIN\"\,/")
  curl -s -b /tmp/cookies.txt -c /tmp/cookies.txt -H "Referer: http://$ROUTER_IP/Advanced_ContentFilter.asp" -H "Content-Type: application/x-www-form-urlencoded" --data "token=$TOKEN&domain=1&target=adblock&data=$(echo $NEW_SETTING | tr -d '\n')" "http://$ROUTER_IP/update.cgi"
done

echo "Blacklisted domains added to Adblock settings."
