#!/bin/bash

# Configuration file path
CONFIG_FILE="./restricted_paths.json"

# Function to apply restrictions
apply_restrictions() {
    local path=$1
    local permissions=$2

    if [ -e "$path" ]; then
        # Change the owner to root and set the specified permissions
        sudo chown -R root:root "$path"
        sudo chmod -R "$permissions" "$path"
    else
        echo "Warning: Path '$path' does not exist."
    fi
}

# Check if jq is installed (for parsing JSON)
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."
    sudo apt-get update && sudo apt-get install -y jq
fi

# Read the configuration file and apply restrictions
if [ -f "$CONFIG_FILE" ]; then
    restricted_resources=$(jq -c '.restricted_resources[]' "$CONFIG_FILE")
    for resource in $restricted_resources; do
        path=$(echo "$resource" | jq -r '.path')
        permissions=$(echo "$resource" | jq -r '.permissions')
        apply_restrictions "$path" "$permissions"
    done
else
    echo "Configuration file '$CONFIG_FILE' not found."
fi
